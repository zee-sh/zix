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
