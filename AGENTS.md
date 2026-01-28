# Agents Guide to This Repository

This repository hosts a modular Neovim configuration built around two custom plugins: `autoconf.nvim` and `themekit.nvim`. It is designed to be easily configurable via TOML files, similar to the Helix editor.

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

## Rules for Agents

1. **Prioritize TOML**: When asked to change a setting, check if it can be done in `config.toml` or `languages.toml` first.
2. **Theme Files**: Create new files in `themes/` for new themes. Do not hardcode theme colors in Lua.
3. **Respect Structure**: Maintain the separation between configuration data (TOML) and logic (Lua plugins).
