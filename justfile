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

# Enable the versioned git hooks in .githooks (one-time, per clone)
hooks:
    git config core.hooksPath .githooks
    @echo "hooks enabled: $(git config core.hooksPath)"

# Run the CI checks locally (fmt + eval); fmt rewrites files before failing
ci:
    nix run --inputs-from . nixpkgs#nixfmt-tree -- --ci
    @# Hosts are discovered, not listed — deleting one must not break CI.
    for h in $(nix eval --json .#darwinConfigurations --apply builtins.attrNames | tr -d '[]"' | tr ',' ' '); do \
        echo "eval $h"; \
        nix eval --raw ".#darwinConfigurations.$h.system.drvPath" >/dev/null || exit 1; \
    done
    @echo "CI checks passed."
