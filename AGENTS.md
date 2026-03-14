# Agents Guide to This Repository

This repository hosts a modular Neovim configuration built around two custom plugins: `autoconf.nvim` and `themekit.nvim`. It is designed to be easily configurable via TOML files, similar to the Helix editor. **Performance is the top priority** — every change must be optimized for fast startup and runtime responsiveness.

## Repositories

This project spans four independent git repositories:

| Repository | Path | Remote | Branch |
|---|---|---|---|
| **nvim-config** | `.` (root) | `git@github.com:OlegHQ/nvim-config.git` | `dev` |
| **autoconf.nvim** | `pack/plugins/start/autoconf.nvim` | `git@github-personal:OlegHQ/autoconf.nvim` | `dev` |
| **themekit.nvim** | `pack/plugins/start/themekit.nvim` | `git@github-personal:OlegHQ/themekit.nvim` | `dev` |
| **nixos-config** | `nixos-config/` | `git@github-personal:OlegHQ/nixos-config.git` | `main` |

### Flake

The nvim-config root has a `flake.nix` that pins `autoconf-nvim` and `themekit-nvim` as flake inputs. After pushing changes to either plugin, run `nix flake update` from the nvim-config root to update `flake.lock` with the latest commits.

```sh
cd ~/.config/nvim
nix flake update
```

### Commit and Push Rules

- `autoconf.nvim` and `themekit.nvim` live as independent git repos inside `pack/plugins/start/`. The `pack/` directory is gitignored by nvim-config, so each plugin has its own git history.
- `nixos-config/` is also a separate git repo (gitignored by nvim-config).
- **Always commit and push from within the plugin/config directory**, not from the root:
  ```sh
  cd pack/plugins/start/autoconf.nvim
  git add -A && git commit -m "your message" && git push
  ```
- The parent nvim-config repo does **not** track plugin or nixos-config contents — do not attempt to commit their changes from the root repo.

## Performance

Performance is the core design principle. Startup time and runtime responsiveness must remain fast.

- Avoid unnecessary computation, redundant loops, duplicate lookups, or eager loading.
- Minimize autocommands — prefer scoped events (`FileType`, `LspAttach`) over global ones.
- Do not introduce external plugin managers or heavy dependencies. The `pack/plugins/start/` structure provides native Neovim package loading with zero overhead.
- Prefer lazy `require()` calls (inside function bodies / resolvers) over top-level requires in `init.lua`.
- Profile with `nvim --startuptime /tmp/startup.log` when changes may affect startup.

## Project Structure

- **`config.toml`**: The primary entry point for user configuration. Modify this file to change:
    - Editor settings (e.g., line numbers, cursor shape).
    - Theme selection (`theme = "name"`).
    - Key bindings.
- **`languages.toml`**: Defines language-specific settings:
    - LSP server configuration.
    - Formatter preferences.
    - Tab width and expansion settings per language.
- **`init.lua`**: The Lua bootstrap file.
    - **Note**: Avoid editing this file for standard configuration changes. Use the TOML files instead.
    - It wires up the `autoconf` resolver system and defines the `open_theme_picker` command.
- **`themes/`**: Contains theme definition files in TOML format.
    - New themes should be added here as `.toml` files.
    - Follow the structure of existing themes (e.g., `themes/github_light.toml`).
- **`pack/plugins/start/`**: Location of bundled plugins.
    - **`autoconf.nvim`**: Handles the TOML configuration loading and resolution logic.
    - **`themekit.nvim`**: Manages theme loading and application.

## Working with Themes

To add or modify themes, work within the `themes/` directory. Themes use a specific TOML schema compatible with Helix themes.

**Example Theme Structure:**

```toml
[palette]
blue = "#0000ff"
red = "#ff0000"

"ui.background" = { bg = "white" }
"string" = "red"
"function" = "blue"
```

## Adding Languages

To add support for a new language, append a `[[language]]` block to `languages.toml`.

**Example:**

```toml
[[language]]
name = "rust"
lsp = "rust_analyzer"
formatter = "rustfmt"
tab = { width = 4, expand = true }
```

## Plugin Architecture

- **`autoconf.nvim`**:
    - Defines "resolvers" that map configuration keys (e.g., `editor.theme`) to Lua functions.
    - Manages the lifecycle of configuration application.
- **`themekit.nvim`**:
    - Scans the `themes/` directory for `.toml` files.
    - Provides the `:ThemePicker` command.

## Nix-Managed Plugins

Third-party Neovim plugins are installed via NixOS/nix-darwin, **not** by a Neovim plugin manager. The plugin list lives in:

- **`nixos-config/home/default.nix`** — under `programs.neovim.plugins`

To add, remove, or update a plugin, edit that Nix file and run `make switch` from `nixos-config/`. Do **not** manually place plugin directories in `pack/` for Nix-managed plugins — only `autoconf.nvim` and `themekit.nvim` live there as custom plugins.

## Performance Regression Prevention

Before and after any change that touches plugin loading, autocommands, or `init.lua`:

1. **Measure startup**: Run `nvim --headless --startuptime /tmp/startup.log -c 'quit'` and check the final `--- NVIM STARTED ---` line.
2. **Baseline**: Startup must stay under **150ms** (current baseline ~134ms). If a change adds more than 10ms, investigate and optimize.
3. **No eager loading**: Completion, formatting, and heavy plugins must be deferred (InsertEnter, vim.schedule, or similar). Never `require()` them at the top level of `init.lua` or resolver modules.
4. **No new autocommands on `*`**: Prefer scoped events (`FileType`, `LspAttach`, `InsertEnter`) over global `BufEnter` / `BufRead` patterns.
5. **Profile after changes**: Review `/tmp/startup.log` for any new module that takes >5ms. If found, defer it or lazy-load it.

## Rules for Agents

1. **Prioritize TOML**: When asked to change a setting, check if it can be done in `config.toml` or `languages.toml` first.
2. **Theme Files**: Create new files in `themes/` for new themes. Do not hardcode theme colors in Lua.
3. **Respect Structure**: Maintain the separation between configuration data (TOML) and logic (Lua plugins).
4. **Plugin commits go to plugin repos**: When editing `autoconf.nvim` or `themekit.nvim`, always commit and push from within `pack/plugins/start/<plugin>/` — never from the root config repo.
5. **Nix plugin changes go to `nixos-config/home/default.nix`**: When adding/removing third-party plugins, edit the Nix plugin list — not the Neovim config directory.
6. **Optimize everything**: Every change — whether to config, themes, or plugins — must prioritize performance. Avoid unnecessary work, prefer lazy patterns, and keep the startup path minimal.

