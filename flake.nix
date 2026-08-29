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
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      # Take brew-src from us rather than from nix-homebrew's own lock.
      inputs.brew-src.follows = "brew-src";
    };

    # The Homebrew core itself, pinned explicitly.
    #
    # With mutableTaps = true the cask tap floats to whatever upstream publishes,
    # but the core that has to *parse* those casks only moves when nix-homebrew
    # cuts a release. That gap is a real failure mode: casks adopt new DSL stanzas
    # as soon as they ship, and a core older than the stanza aborts activation.
    # It bit us once already — a firefox cask using `command_wrapper` (added in
    # brew 6.0.13) against a pinned 6.0.12 failed `brew bundle` with
    # "undefined method 'command_wrapper'".
    #
    # Declaring brew-src here decouples the two: bump this tag when a cask needs a
    # newer core, without waiting on a nix-homebrew release.
    brew-src = {
      url = "github:Homebrew/brew/6.0.20";
      flake = false;
    };

    # sops-nix (secrets) added when needed.
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ (inputs.import-tree ./modules) ];
    };
}
