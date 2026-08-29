default:
    @just --list

# Build a host's config without activating (default: current machine)
build host=`hostname -s`:
    darwin-rebuild build --flake .#{{host}}

# Build and activate a host's config (default: current machine)
switch host=`hostname -s`:
    sudo darwin-rebuild switch --flake .#{{host}}

# NOTE: first-time activation on a fresh machine is NOT a just recipe — just isn't
# installed yet. See BOOTSTRAP.md for the raw bootstrap commands.

# Update all flake inputs
update:
    nix flake update

# Evaluate/check the flake
check:
    nix flake check

# Format all nix files
fmt:
    nix fmt

# Enable the versioned git hooks in .githooks (one-time, per clone).
# Currently just a pre-commit formatting gate.
hooks:
    git config core.hooksPath .githooks
    @echo "hooks enabled: $(git config core.hooksPath)"

# Run exactly what CI runs, locally. Same commands as .github/workflows/ci.yml,
# so a green run here means a green run there — worth doing before pushing,
# since this repo is private and Actions minutes are billed.
#
# Note the formatter runs in --ci mode: it rewrites unformatted files and *then*
# exits non-zero, so a failure leaves the fixes already applied in your tree.
ci:
    nix run --inputs-from . nixpkgs#nixfmt-tree -- --ci
    nix eval --raw .#darwinConfigurations.m2air.system.drvPath
    nix eval --raw .#darwinConfigurations.m4max.system.drvPath
    @echo "CI checks passed."
