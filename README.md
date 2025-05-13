# Neovim Configuration

A modern, feature-rich Neovim configuration written in Fennel, using the power of Lua and Neovim's native capabilities.

## Features

- 🎨 Beautiful UI with Catppuccin Latte theme
- 🔍 Telescope integration for fuzzy finding
- 📝 LSP support for multiple languages
- 🎯 Code completion with nvim-cmp
- 🌳 Tree-sitter integration for better syntax highlighting
- 💬 Comment.nvim for easy code commenting
- 📊 Git integration with gitsigns
- 🎨 Conform.nvim for code formatting

## Prerequisites

- Neovim 0.9.0 or higher
- [Hotpot.nvim](https://github.com/rktjmp/hotpot.nvim) for Fennel compilation
- Git
- A Nerd Font (recommended for icons)

## Installation

1. Clone this repository:
```bash
git clone <your-repo-url> ~/.config/nvim
```

2. Install required plugins manually:

```bash
# Create plugins directory
mkdir -p ~/.local/share/nvim/site/pack/plugins/start

# Install Hotpot.nvim (required for Fennel compilation)
git clone https://github.com/rktjmp/hotpot.nvim ~/.local/share/nvim/site/pack/plugins/start/hotpot.nvim

# Install Treesitter
git clone https://github.com/nvim-treesitter/nvim-treesitter ~/.local/share/nvim/site/pack/plugins/start/nvim-treesitter

# Install Telescope and its dependencies
git clone https://github.com/nvim-lua/plenary.nvim ~/.local/share/nvim/site/pack/plugins/start/plenary.nvim
git clone https://github.com/nvim-telescope/telescope.nvim ~/.local/share/nvim/site/pack/plugins/start/telescope.nvim

# Install LSP
git clone https://github.com/neovim/nvim-lspconfig ~/.local/share/nvim/site/pack/plugins/start/nvim-lspconfig

# Install Completion
git clone https://github.com/hrsh7th/nvim-cmp ~/.local/share/nvim/site/pack/plugins/start/nvim-cmp
git clone https://github.com/hrsh7th/cmp-nvim-lsp ~/.local/share/nvim/site/pack/plugins/start/cmp-nvim-lsp

# Install Comment.nvim
git clone https://github.com/numToStr/Comment.nvim ~/.local/share/nvim/site/pack/plugins/start/Comment.nvim

# Install Gitsigns
git clone https://github.com/lewis6991/gitsigns.nvim ~/.local/share/nvim/site/pack/plugins/start/gitsigns.nvim

# Install Conform.nvim
git clone https://github.com/stevearc/conform.nvim ~/.local/share/nvim/site/pack/plugins/start/conform.nvim

# Install Catppuccin theme
git clone https://github.com/catppuccin/nvim ~/.local/share/nvim/site/pack/plugins/start/catppuccin
```

3. Update Treesitter parsers:
```bash
nvim --headless -c "TSUpdate" -c "quit"
```

## Configuration Structure

The configuration is organized into several key components:

### Core Configuration (`x.fnl`)

- **Editor Settings**: Basic Neovim settings like tab width, line numbers, and colors
- **Language Support**: LSP and formatter configurations for various programming languages
- **Feature Flags**: Toggle specific features on/off
- **Theme Configuration**: Currently using Catppuccin Latte theme

### Language Support

The configuration includes support for:
- TypeScript/JavaScript (tsserver + Biome)
- Python (pyright + Black)
- Go (gopls + goimports/gofmt)
- Rust
- Swift (sourcekit + swiftformat)
- OCaml (ocamllsp + ocamlformat)
- And more...

### Key Mappings

- `<Space>` as leader key
- `,` as local leader key
- Telescope:
  - `<leader>f` - Find files
  - `<leader>/` - Live grep
  - `<leader>d` - Show diagnostics
  - `<leader>b` - List buffers
- LSP:
  - `<leader>k` - Hover documentation
  - `<leader>r` - Rename symbol
  - `<leader>a` - Code actions
  - `<leader>e` - Show diagnostics
  - `gd` - Go to definition
  - `gy` - Go to type definition
  - `gr` - Go to references
  - `gi` - Go to implementation

## Customization

### Adding New Languages

To add support for a new language, modify the `:languages` table in `x.fnl`:

```fennel
:languages
  { :your-language { :lsp "your-lsp-server" :formatter "your-formatter" }}
```

### Enabling/Disabling Features

Features can be toggled in the `:features` table:

```fennel
:features 
  { :feature-name true/false }
```

### Theme Configuration

Themes can be configured in the `:themes` table:

```fennel
:themes 
  { :theme-name true/false }
```

## Production Readiness

This configuration is production-ready with:

- ✅ Stable plugin versions
- ✅ Comprehensive LSP support
- ✅ Efficient key mappings
- ✅ Proper error handling
- ✅ Performance optimizations
- ✅ Modular and maintainable code structure

## Troubleshooting

1. **LSP not working**: Ensure the language server is installed on your system
2. **Treesitter errors**: Run `:TSUpdate` to update parsers
3. **Plugin issues**: Check if all plugins are properly installed in the correct directory
4. **Plugin not loading**: Verify the plugin is in the correct directory (`~/.local/share/nvim/site/pack/plugins/start/`)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 