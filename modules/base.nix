{ config, ... }:
let
  inherit (config.flake.modules)
    generic
    darwin
    homeManager
    ;

  # Applied to every system config (darwin now, nixos later).
  commonImports = [
    generic.toggles
    generic.profile
    generic.primaryUser
    generic.primaryUserHome
    generic.profilePersonal
    generic.profileWork
  ];
in
{
  # home-manager wiring shared by all system configs. Imported by
  # configurations/darwin.nix into each darwinSystem.
  flake.modules.generic.homeManagerIntegration = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-bak";
    };
  };

  # The darwin "catalog": every darwin feature is imported here and gated by its
  # own `zix.<f>.enable` toggle (off by default). Enabling a toggle turns it on.
  flake.modules.darwin.base = {
    imports = commonImports ++ [
      darwin.users
      darwin.systemBase
      darwin.systemPreferences
      darwin.homebrew
      darwin.nixpkgsWork
    ];
    home-manager.sharedModules = [ homeManager.base ];
  };

  # The home-manager "catalog": every HM feature imported here, each gated by
  # `osConfig.zix.<f>.enable`.
  flake.modules.homeManager.base = {
    imports = [
      homeManager.git
      homeManager.direnv
      homeManager.cli
      homeManager.zsh
      homeManager.nushell
      homeManager.starship
      homeManager.tmux
      homeManager.zellij
      homeManager.ghostty
      homeManager.herdr
      homeManager.aliases
      homeManager.packages
    ];
  };
}
