# 🚀 Neovim Configuration Demo

A simple Neovim configuration demonstrating the power of `autoconf.nvim` and `themekit.nvim` plugins.

![Neovim](https://img.shields.io/badge/Neovim-0.9.0+-57A143?style=for-the-badge&logo=neovim&logoColor=white)
![Lua](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

## ✨ Features

### 🎨 **Theme Management with themekit.nvim**

- **Multiple Built-in Themes**: Collection of carefully curated themes
- **Live Theme Switching**: Change themes on-the-fly with `Space + t`
- **Theme Picker**: Interactive theme selection interface
- **Auto-Configuration**: Seamless theme integration

### 🔧 **Configuration Management with autoconf.nvim**

- **Modular Architecture**: Clean separation of concerns
- **Auto-Configuration Resolvers**: Dynamic configuration management
- **Lifecycle Management**: Proper initialization order handling
- **TOML Configuration**: Human-readable configuration format

### 🌍 **Language Support**

- **Multi-Language LSP**: Full Language Server Protocol support
- **Smart Formatting**: Automatic code formatting with language-specific tools
- **Syntax Highlighting**: Enhanced syntax highlighting

## 🚀 Quick Start

### Prerequisites

- **Neovim 0.9.0+** (latest stable recommended)
- **Git** for installation
- **Node.js** (for LSP servers)

### Installation

1. **Clone the configuration**:

   ```bash
   git clone https://github.com/nexo-tech/nvim-config.git ~/.config/nvim
   cd ~/.config/nvim
   ```

2. **Install dependencies**:

   ```bash
   # Install LSP servers
   npm install -g typescript-language-server @biomejs/biome

   # Install Go tools
   go install golang.org/x/tools/gopls@latest
   go install golang.org/x/tools/cmd/goimports@latest

   # Install Rust tools
   rustup component add rust-analyzer rustfmt
   ```

3. **Start Neovim**:
   ```bash
   nvim
   ```

## 🎯 Usage

### Basic Commands

| Command        | Description                      |
| -------------- | -------------------------------- |
| `Space + t`    | Open theme picker                |
| `:ThemePicker` | Alternative theme picker command |
| `:checkhealth` | Check system health              |

### Theme Management

#### Changing Themes

```lua
-- In your config.toml
[editor]
theme = "ayu_dark"  -- Change this to any theme name
```

#### Popular Themes

- **Dark**: `catppuccin_mocha`, `tokyonight`, `onedark`, `gruvbox`
- **Light**: `github_light`, `solarized_light`, `rose_pine_dawn`
- **Special**: `modus_vivendi`, `everforest_dark`, `kanagawa`

## ⚙️ Configuration

### File Structure

```
~/.config/nvim/
├── init.lua              # Main initialization
├── config.toml           # Editor configuration
├── languages.toml        # Language-specific settings
├── themes/               # Theme collection
│   ├── *.toml           # Individual theme files
│   └── licenses/        # Theme licenses
└── README.md            # This file
```

### Configuration Files

#### `config.toml` - Main Configuration

```toml
[editor]
theme = "ayu_dark"

[editor.whitespace]
render = "none"

[editor.cursor-shape]
normal = "block"
insert = "block"
select = "block"

[keys.normal.space]
t = "open_theme_picker"
```

#### `languages.toml` - Language Support

```toml
[[language]]
name = "python"
lsp = "pyright"
formatter = "black"
tab = { width = 4, expand = true }

[[language]]
name = "typescript"
lsp = "ts_ls"
formatter = "biome"
tab = { width = 4, expand = false }
```

#### `init.lua` - Core Initialization

```lua
local autoconf = require("autoconf")
local themekit = require("themekit")

autoconf.define_resolver("editor.theme", {
    resolver = function(name) return themekit.apply(name) end,
    lifecycle = autoconf.Lifecycle.LATE,
})
autoconf.define_command_resolver("open_theme_picker",
    function(_) return vim.cmd("ThemePicker") end)
```

## 🔧 Customization

### Adding Custom Themes

1. **Create a new theme file** in `themes/`:

   ```toml
   # themes/my_theme.toml
   # Author: Your Name <your.email@domain.com>

   "comment" = { fg = "gray", modifiers = ["italic"] }
   "string" = "green"
   "keyword" = "red"
   "function" = "blue"
   # ... more syntax highlighting rules
   ```

2. **Update your configuration**:
   ```toml
   [editor]
   theme = "my_theme"
   ```

### Extending Language Support

Add new languages to `languages.toml`:

```toml
[[language]]
name = "your_language"
lsp = "your_lsp_server"
formatter = "your_formatter"
tab = { width = 2, expand = true }
```

## 🛠️ Troubleshooting

### Common Issues

#### LSP Not Working

1. **Check LSP installation**:

   ```bash
   # For TypeScript
   npm list -g typescript-language-server

   # For Python
   pip install pyright
   ```

2. **Verify Neovim version**:
   ```bash
   nvim --version
   # Should be 0.9.0 or higher
   ```

#### Theme Not Loading

1. **Check theme file exists**:
   ```bash
   ls ~/.config/nvim/themes/your_theme.toml
   ```

### Health Check

Run Neovim's health check:

```vim
:checkhealth
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Adding Themes

1. **Fork the repository**
2. **Create your theme** in `themes/your_theme.toml`
3. **Add license** if applicable in `themes/licenses/`
4. **Submit a pull request**

### Code Style

- Use consistent TOML formatting
- Follow existing naming conventions
- Add appropriate comments
- Test your changes thoroughly

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Theme Licenses

Individual themes may have their own licenses. Check the `themes/licenses/` directory for specific theme licenses.

## 🙏 Acknowledgments

- **Helix Editor Team** - For the excellent theme collection
- **Neovim Community** - For the amazing ecosystem
- **Theme Authors** - For creating beautiful themes

## 📚 Resources

### Documentation

- [Neovim Documentation](https://neovim.io/doc/)
- [LSP Configuration](https://neovim.io/doc/user/lsp.html)
- [TOML Specification](https://toml.io/en/)

### Related Projects

- [Helix Editor](https://helix-editor.com/) - Source of many themes
- [Tree-sitter](https://tree-sitter.github.io/tree-sitter/) - Syntax parsing
- [LSP Specification](https://microsoft.github.io/language-server-protocol/)

---

<div align="center">

**Made with ❤️ for the Neovim community**

[⭐ Star this repo](https://github.com/nexo-tech/nvim-config) | [🐛 Report issues](https://github.com/nexo-tech/nvim-config/issues) | [💬 Discuss](https://github.com/nexo-tech/nvim-config/discussions)

</div>
