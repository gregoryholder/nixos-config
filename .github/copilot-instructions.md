# Copilot Instructions for Nix Home Manager Configuration

## Repository Overview

This is a Nix Home Manager configuration repository for managing user environments across multiple systems. It defines shell, terminal, development tools, editor settings, and system utilities using declarative Nix modules.

## Build & Deployment Commands

**Apply configuration to current user:**
```bash
home-manager switch -b backup
```

**Build without switching (test changes):**
```bash
home-manager build
```

**Check flake outputs:**
```bash
nix flake show
```

**Check for Nix errors without applying:**
```bash
nix flake check
```

**Update lock file (update all dependencies):**
```bash
nix flake update
```

## Architecture & Module Structure

The configuration uses a modular hierarchy:

- **`flake.nix`** - Entry point. Defines inputs (nixpkgs, home-manager, nixGL) and creates two home configurations: `home` (for gregory user) and `work` (for dev user). Uses `mkHomeConfig` helper to reduce duplication.

- **`home.nix`** - Base configuration applied to all profiles. Imports `config-programs`, `config-features`, and `lib`. Sets up core Home Manager features.

- **`config-programs/`** - High-level program configurations:
  - `shell/` - Zsh setup (aliases, keybindings, plugins, fnm for Node version management)
  - `terminal/` - Terminal emulator configs (Alacritty, WezTerm, Zellij, Lazygit)
  - `oh-my-posh.nix` - Shell prompt configuration
  
- **`config-features/`** - Feature modules:
  - `dev-env/` - Development environment (build tools, git settings, proxy)
  - `build-tools/` - Build system packages and environment variables

- **`lib/`** - Shared packages and utilities (nil for Nix LSP, nixfmt, media tools, system utilities)

- **`home/` & `work/`** - Environment-specific overrides. Work includes SSH agent and custom aliases for non-NixOS systems.

## Key Conventions

### Module Imports Pattern
All subdirectories use `imports = [ ... ];` to compose configuration:
```nix
{ ... }:
{
  imports = [
    ./submodule1
    ./submodule2
  ];
}
```

### Environment Variables Setup
Session variables go in `home.sessionVariables`:
```nix
home.sessionVariables = {
  VARIABLE_NAME = "value";
};
```

### Program Configuration
Use Home Manager's built-in program modules:
```nix
programs.zsh = { ... };
programs.git = { ... };
programs.helix = { ... };
```

### Composition with lib.mkAfter / lib.mkBefore
Use these when appending/prepending to existing configuration values in derived modules (e.g., `initExtra = lib.mkAfter ''...''`)

### Username Portability
The `currentUsername` is passed through `extraSpecialArgs` in flake.nix, allowing configurations to work across different usernames without duplication:
```nix
home.username = currentUsername;
home.homeDirectory = "/home/${currentUsername}";
```

### File Organization
- One feature/program per directory or file
- `default.nix` always contains imports; specific settings go in dedicated `.nix` files
- Large configurations (100+ lines) get their own file (e.g., `keybindings.nix`, `oh-my-posh.nix`)

## Notable Customizations

- **Git Configuration**: Custom aliases (`pick`, `rinse`), delta for diff viewing, merge tool set to bcompare, LFS enabled
- **Shell Aliases**: Color variants for grep/ls (lsd), git shortcuts (gp, gaa, gr), Node version shortcut (node8), remote Neovim editing (nvr)
- **Development Tools**: CCACHE settings for build optimization, Zellij auto-exit, custom proxy configuration for GitLab
- **Editor**: Helix with LSP inlay hints, relative line numbers, onedark theme

## Adding New Configuration

1. Create a new `.nix` file or directory following existing structure
2. Add the import to the parent module's `default.nix`
3. Test with `home-manager build` before applying
4. Use `home-manager switch -b backup` to apply and keep a backup

## Viewing Active Configuration

After applying, view what's been set in your environment:
```bash
home-manager generations  # List applied configurations
nix-shell -A home-manager --run "nix-shell" # Enter shell with all packages
```
