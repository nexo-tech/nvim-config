# Agents Guide to This Repository

This repository hosts a modular Neovim configuration built around `autoconf.nvim` and `themekit.nvim`, with a planned workspace subsystem in `workbench.nvim`. Configuration stays in TOML. **Performance is the top priority**, including startup, first use, active interaction, and cleanup.

## Workbench Development Entry

The workbench repository currently contains a detailed implementation specification, not a working plugin. For workbench implementation or review, read its [AGENTS.md](pack/plugins/start/workbench.nvim/AGENTS.md), [plan](pack/plugins/start/workbench.nvim/docs/PLAN.md), and [implementation skill](pack/plugins/start/workbench.nvim/.agents/skills/workbench-implementation/SKILL.md). For host integration, use [.agents/skills/workbench-integration/SKILL.md](.agents/skills/workbench-integration/SKILL.md).

- Follow the task graph, module ownership, contracts and completion gates. A plan check is not a runtime test. Do not mark unfinished dependencies or unrun gates complete.
- Workbench owns workspace state, results, navigation, views and discovery. Autoconf owns TOML and editor feature setup; themekit owns semantic theme mappings; this root owns user defaults, integration and gitlinks; Nix owns third-party installation.
- The current request determines planning versus implementation scope. Gates require evidence, not repeated user permission. Continue authorized reversible work without asking again.
- Claim a dependency-ready task, identify its repositories and owned paths, implement success/error/disposal together, then record reproducible evidence. No placeholder implementation or log-only success can satisfy a gate.

## Repositories

This project spans five independent git repositories (the Nix checkout may not be present locally):

| Repository | Path | Remote | Branch |
|---|---|---|---|
| **nvim-config** | `.` (root) | `git@github.com:OlegHQ/nvim-config.git` | `dev` |
| **autoconf.nvim** | `pack/plugins/start/autoconf.nvim` | `git@github.com:OlegHQ/autoconf.nvim` | `dev` |
| **themekit.nvim** | `pack/plugins/start/themekit.nvim` | `git@github.com:OlegHQ/themekit.nvim` | `dev` |
| **workbench.nvim** | `pack/plugins/start/workbench.nvim` | `git@github.com:OlegHQ/workbench.nvim.git` | `dev` |
| **nixos-config** | `nixos-config/` | `git@github-personal:OlegHQ/nixos-config.git` | `main` |

### Flake

The root `flake.nix` pins `autoconf-nvim` and `themekit-nvim`. Workbench runtime input/install wiring is task WB-25; its planning-only submodule has no runtime input yet. After publishing runtime plugin changes, update the relevant inputs from the root and inspect the lock diff. Prefer targeted updates to avoid unrelated nixpkgs churn; verify syntax with the installed Nix version.

```sh
cd ~/.config/nvim
nix flake update autoconf-nvim themekit-nvim
```

### Commit and Push Rules

- Custom plugins are git submodules under `pack/plugins/start/`. Each plugin keeps its own git history, while nvim-config tracks the exact plugin commit as a gitlink (mode 160000).
- Clone nvim-config with `git clone --recurse-submodules`, or initialize an existing checkout with `git submodule update --init --recursive`.
- New submodule URLs must use the `git@github.com:OlegHQ/<plugin>.git` SSH form. Custom plugin submodules track `dev` in `.gitmodules`. Publish plugin commits before referencing them in parent gitlinks or runtime Nix pins.
- `nixos-config/` is also a separate git repo (gitignored by nvim-config).
- **Always commit and push plugin code from within the plugin directory**, not from the root:
  ```sh
  cd pack/plugins/start/autoconf.nvim
  git status --short
  # Stage only the reviewed task-owned files, then commit and push.
  ```
- After pushing a plugin commit, return to the nvim-config root, stage the changed submodule path, and commit and push the updated gitlink:
  ```sh
  cd ~/.config/nvim
  git add pack/plugins/start/autoconf.nvim
  git commit -m "chore: update autoconf.nvim submodule"
  git push
  ```
- The parent nvim-config repo tracks plugin commit pointers, not plugin file contents. It does not track `nixos-config/` contents.
- Do not use `make sync` as a shortcut for scoped work: it stages all changes, updates broad inputs and assumes the Nix checkout exists. Inspect each repository separately and preserve unrelated edits.
- A documentation-only workbench revision does not authorize enabling a runtime or performing a host switch. Follow the [integration runbook](pack/plugins/start/workbench.nvim/docs/INTEGRATION.md) for releases.

## Performance

Performance is the core design principle. Startup time and runtime responsiveness must remain fast.

- Avoid unnecessary computation, redundant loops, duplicate lookups, or eager loading.
- Minimize autocommands — prefer scoped events (`FileType`, `LspAttach`) over global ones.
- Do not introduce external plugin managers or heavy dependencies. Native `pack/plugins/start/` discovery and plugin entrypoints still have measurable overhead; keep entrypoints minimal.
- Prefer lazy `require()` calls (inside function bodies / resolvers) over top-level requires in `init.lua`.
- Profile with `nvim --startuptime /tmp/startup.log` when changes may affect startup.
- `vim.schedule()` queues main-loop work; it is not background execution and does not prove the UI has painted. Measure first input, first action and sustained interaction as well as the startup marker.
- Processes, timers, watchers, subscriptions, buffers and windows require a named owner and idempotent disposal. Reject stale asynchronous results after disable, root change or view close.

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
    - **`workbench.nvim`**: Planning/specification repository for workspace navigation and discovery; runtime implementation is gated by its task graph.

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

To add, remove, or update a third-party plugin, edit that Nix file and validate/build before running `make switch` from the actual Nix checkout. If it is missing, complete independent work and report the exact unverified host gate. Do **not** manually place Nix-managed plugin directories in `pack/`; custom plugins `autoconf.nvim`, `themekit.nvim`, and `workbench.nvim` belong there as separate submodules.

## Performance Regression Prevention

Before and after any change that touches plugin loading, autocommands, or `init.lua`:

1. **Measure startup**: Run `nvim --headless --startuptime /tmp/startup.log -c 'quit'` with a fresh log path per run; Neovim appends to existing logs. Check the final `--- NVIM STARTED ---` line and relevant first-use costs.
2. **Baseline**: Startup must stay under **150ms** on the reference host. Historical documents cite different baselines; measure the current checkout. If a change adds more than 10ms, investigate and optimize.
3. **No eager heavy loading**: Defer completion UI to insert/use and formatting to first relevant save/format action, including saves before InsertEnter. Obtain required LSP capabilities before client initialization. Never eagerly require heavy plugins at the top level of `init.lua` or resolver modules.
4. **Scoped autocommands**: Prefer buffer-scoped events and `FileType`/`LspAttach` over global `BufEnter`/`BufRead`. A necessary application lifecycle event must have one documented owner, an O(1) inactive path, and disposal coverage. Never blanket-clear another component's autocommands.
5. **Profile after changes**: Review `/tmp/startup.log` for any new module that takes >5ms. If found, defer it or lazy-load it.

## Rules for Agents

1. **Prioritize TOML**: When asked to change a setting, check if it can be done in `config.toml` or `languages.toml` first.
2. **Theme Files**: Create new files in `themes/` for new themes. Do not hardcode theme colors in Lua.
3. **Respect Structure**: Maintain the separation between configuration data (TOML) and logic (Lua plugins).
4. **Respect submodule boundaries**: Commit and push plugin code from within `pack/plugins/start/<plugin>/`, then commit the updated submodule gitlink from the nvim-config root. Never commit plugin file contents directly from the root repo.
5. **Nix plugin changes go to `nixos-config/home/default.nix`**: When adding/removing third-party plugins, edit the Nix plugin list — not the Neovim config directory.
6. **Optimize everything**: Every change — whether to config, themes, or plugins — must prioritize performance. Avoid unnecessary work, prefer lazy patterns, and keep the startup path minimal.
7. **Verify settings**: A successful resolver log is not proof of an applied setting. Test effective state, false values, repeated enable/disable, and cleanup without sibling interference.
8. **Respect completion gates**: Workbench tasks require ownership, behavior, lifecycle, UX, performance, compatibility and applicable mutation/release evidence. Do not weaken a gate to make a task appear done.
