---
name: workbench-integration
description: Integrate workbench.nvim into this Neovim configuration across TOML, autoconf, themekit, native submodules and Nix, using the workbench implementation plan and release gates. Use for workbench host changes, not ordinary standalone editor settings.
---

# Workbench Host Integration

Locate the nvim-config Git root and inspect its `AGENTS.md`, `.gitmodules`, `flake.nix`, and each affected repository's status. The plugin lives at `pack/plugins/start/workbench.nvim` and has its own Git history.

Read the plugin [plan](../../../pack/plugins/start/workbench.nvim/docs/PLAN.md), [integration runbook](../../../pack/plugins/start/workbench.nvim/docs/INTEGRATION.md), [validation gates](../../../pack/plugins/start/workbench.nvim/docs/VALIDATION.md), and [implementation skill](../../../pack/plugins/start/workbench.nvim/.agents/skills/workbench-implementation/SKILL.md). Run `python3 scripts/check_plan.py --next` from the plugin root. Use the task requested by the user; do not infer that every planned capability should be enabled.

Autoconf owns editor feature lifecycle and TOML translation. Workbench owns its workspace/UI subsystem. Themekit owns semantic color mapping. The parent owns defaults, mappings and gitlinks. Nix owns third-party installation. Identify the task's owner before editing; cross-repository changes require separate diffs, tests and commits.

The current planning-only plugin must not be mistaken for an installed feature. Runtime input/wiring is WB-25 after its prerequisites. Verify false settings, mapping precedence, saved-state compatibility, startup/first-use performance and disabling cleanup. Do not silently add nested key namespaces before checking autoconf's key parser supports them.

Run all checks locally. Do not add GitHub Actions or other hosted CI. Host acceptance requires local end-to-end tests through real Neovim input and rendered windows, with real providers where applicable. Keep reproducible local logs and evidence; unit tests alone cannot establish a working editor workflow.

When publication is within the active request, publish plugin commits first, update parent gitlinks and relevant runtime lock inputs second, and verify exact revision consistency. Avoid broad `make sync`. If the Nix checkout is absent, complete independent work and identify the blocked host gate; do not fabricate activation evidence. Gates require proof, not repeated permission for already authorized work.
