{
  description = "Neovim configuration with autoconf.nvim and themekit.nvim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    autoconf-nvim = {
      url = "github:nexo-tech/autoconf.nvim";
      flake = false;
    };

    themekit-nvim = {
      url = "github:nexo-tech/themekit.nvim";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, autoconf-nvim, themekit-nvim, ... }:
    let
      supportedSystems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Configuration files from this repo
      configFiles = {
        "init.lua" = ./init.lua;
        "config.toml" = ./config.toml;
        "languages.toml" = ./languages.toml;
      };

      # Theme files directory
      themesDir = ./themes;
    in {
      # Home Manager module
      homeManagerModules.default = { config, lib, pkgs, ... }:
        let cfg = config.programs.nvimconf;
        in {
          options.programs.nvimconf = {
            enable = lib.mkEnableOption
              "nvimconf - Neovim configuration with autoconf.nvim and themekit.nvim";

            package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.neovim-unwrapped;
              defaultText = lib.literalExpression "pkgs.neovim-unwrapped";
              description = "The Neovim package to use.";
            };

            extraConfig = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "Extra Lua configuration to append to init.lua";
            };

            theme = lib.mkOption {
              type = lib.types.str;
              default = "catppuccin_macchiato";
              description = "Default theme to use";
            };

            themeMode = lib.mkOption {
              type = lib.types.nullOr (lib.types.enum [ "light" "dark" ]);
              default = null;
              description = ''
                Theme mode (light or dark). When set, automatically selects
                the appropriate theme variant. For example, with catppuccin:
                - "light" selects catppuccin_latte
                - "dark" selects catppuccin_macchiato
                This overrides the theme option if both are set.
              '';
            };
          };

          config = lib.mkIf cfg.enable (let
            # Determine effective theme based on themeMode
            effectiveTheme = if cfg.themeMode != null then
              (if cfg.themeMode == "light" then
                "catppuccin_latte"
              else
                "catppuccin_macchiato")
            else
              cfg.theme;
          in {
            programs.neovim = {
              enable = true;
              package = cfg.package;

              # Ensure Neovim can find our plugins and config
              extraPackages = with pkgs;
                [
                  # Add any runtime dependencies here
                ];
            };

            # Create the nvim configuration directory structure
            xdg.configFile = {
              # Main init.lua with optional extra config
              "nvim/init.lua".text = ''
                ${builtins.readFile ./init.lua}
                ${cfg.extraConfig}
              '';

              # TOML configuration files
              "nvim/config.toml".text = let
                originalConfig = builtins.readFile ./config.toml;

                themeLine = ''theme = "${effectiveTheme}"'';

                replaceEditorTheme = contents:
                  let
                    lines = lib.splitString "\n" contents;

                    step = state: line:
                      let
                        inEditor = state.inEditor || (line == "[editor]");
                        leavingEditor = inEditor && (lib.hasPrefix "[" line)
                          && (line != "[editor]");
                        shouldReplace = inEditor && (!leavingEditor)
                          && (builtins.match ''^theme\s*=\s*".*"$'' line
                            != null);

                        nextLines = state.lines
                          ++ [ (if shouldReplace then themeLine else line) ];
                      in {
                        lines = nextLines;
                        inEditor = inEditor && !leavingEditor;
                        replaced = state.replaced || shouldReplace;
                      };

                    result = builtins.foldl' step {
                      lines = [ ];
                      inEditor = false;
                      replaced = false;
                    } lines;

                    insertIfMissing = ls:
                      let
                        idx =
                          lib.lists.findFirstIndex (x: x == "[editor]") null ls;
                      in if idx == null then
                        ls
                      else
                        (lib.take (idx + 1) ls) ++ [ themeLine ]
                        ++ (lib.drop (idx + 1) ls);

                    finalLines = if result.replaced then
                      result.lines
                    else
                      insertIfMissing result.lines;
                  in lib.concatStringsSep "\n" finalLines;
              in replaceEditorTheme originalConfig;

              "nvim/languages.toml".source = ./languages.toml;

              # Link themes directory
              "nvim/themes".source = themesDir;

              # Plugin: autoconf.nvim
              "nvim/pack/plugins/start/autoconf.nvim".source = autoconf-nvim;

              # Plugin: themekit.nvim
              "nvim/pack/plugins/start/themekit.nvim".source = themekit-nvim;
            };
          });
        };

      # Convenience alias
      homeManagerModules.nvimconf = self.homeManagerModules.default;

      # Packages for standalone use
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          nvimConfig = pkgs.stdenvNoCC.mkDerivation {
            name = "nvimconf";
            src = ./.;

            installPhase = ''
              mkdir -p $out

              # Copy config files
              cp init.lua $out/
              cp config.toml $out/
              cp languages.toml $out/

              # Copy themes
              cp -r themes $out/

              # Copy plugins
              mkdir -p $out/pack/plugins/start
              cp -r ${autoconf-nvim} $out/pack/plugins/start/autoconf.nvim
              cp -r ${themekit-nvim} $out/pack/plugins/start/themekit.nvim
            '';
          };
        in {
          default = nvimConfig;
          nvimconf = nvimConfig;
        });

      # Development shell
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [ neovim ];

            shellHook = ''
              echo "nvimconf development shell"
              echo "Run 'nvim' to test the configuration"
              export XDG_CONFIG_HOME="$(pwd)"
            '';
          };
        });
    };
}
