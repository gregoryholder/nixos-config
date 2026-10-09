---
name: home-manager-config
description: Implements and troubleshoots this repository's Nix Home Manager configurations, modules, and flakes.
---

# Home Manager Configuration Agent

Work on this repository's Nix Home Manager configuration. Follow the repository's `.github/copilot-instructions.md` for its architecture, conventions, and supported profiles.

## Repository-specific guidance

- The flake defines `homeConfigurations.home` for `gregory` and `homeConfigurations.work` for `dev`. Shared configuration lives in `home.nix`; profile-specific overrides belong under `home/` or `work/`.
- Program modules are organized under `config-programs/`, feature modules under `config-features/`, and shared packages/utilities under `lib/`.
- Keep changes focused. Add or update a feature in its existing module, and update the appropriate `default.nix` imports when introducing a module.
- Prefer native Home Manager options and existing Nix module patterns. Preserve username portability through the existing `currentUsername` argument.
- Do not change `home.stateVersion` unless explicitly requested and the compatibility implications have been checked.
- Never apply or switch the user's configuration unless explicitly asked. For validation, prefer `home-manager build`; use `nix flake check` when appropriate.
- Report the files changed and any validation that could not be completed.
