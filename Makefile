# Neovim Config — sync all repos
# Usage: make sync m="commit message"

m ?= update

AUTOCONF  := pack/plugins/start/autoconf.nvim
THEMEKIT  := pack/plugins/start/themekit.nvim
NIXOS     := nixos-config

.PHONY: sync push-autoconf push-themekit push-nvim push-nixos

sync: push-autoconf push-themekit push-nvim push-nixos
	@echo "Done — all repos synced."

push-autoconf:
	@echo "→ autoconf.nvim"
	cd $(AUTOCONF) && git add -A && (git diff --cached --quiet || (git commit -m "$(m)" && git push))

push-themekit:
	@echo "→ themekit.nvim"
	cd $(THEMEKIT) && git add -A && (git diff --cached --quiet || (git commit -m "$(m)" && git push))

push-nvim: push-autoconf push-themekit
	@echo "→ nix flake update"
	nix flake update
	@echo "→ nvim-config"
	git add -A && git diff --cached --quiet || \
		(git commit -m "$(m)" && git push)

push-nixos: push-nvim
	@echo "→ nixos-config (update-nexo + commit)"
	cd $(NIXOS) && nix flake update nvimconf claude-config && \
		git add -A && (git diff --cached --quiet || (git commit -m "$(m)" && git push))
