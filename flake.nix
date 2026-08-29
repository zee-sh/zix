{
  description = "zix — dendritic nix-darwin config for zeeshans' machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

    # Wraps neovim: plugins and language servers come from nix, config stays Lua.
    # Successor to nixCats-nvim (same author); nixCats is in maintenance mode.
    nix-wrapper-modules = {
      url = "github:BirdeeHub/nix-wrapper-modules";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim plugins not in nixpkgs, fetched by the `plugins-` prefix convention.
    plugins-lze = {
      url = "github:BirdeeHub/lze";
      flake = false;
    };
    plugins-lzextras = {
      url = "github:BirdeeHub/lzextras";
      flake = false;
    };

    # Installs + pins Homebrew declaratively. mutableTaps stays true, so no
    # homebrew-core/cask git inputs are needed (obsolete under Homebrew API mode).
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # sops-nix (secrets) added when needed.
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ (inputs.import-tree ./modules) ];
    };
}
