{
  # nixfmt-tree (a treefmt wrapper around nixfmt) rather than nixfmt directly:
  # bare nixfmt deprecates being handed a directory, so `nix fmt .` and
  # `nix fmt -- --check .` both warn. The wrapper walks the tree itself, respects
  # .gitignore, and supports --check for CI.
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-tree;
    };
}
