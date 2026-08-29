{ config, ... }:
let
  inherit (config.flake.modules) darwin;
in
{
  configurations.darwin."m4max".module =
    { config, ... }:
    {
      imports = [ darwin.base ];

      primaryUser = config.profile.username;
      system.stateVersion = 5; # existing machine (in-place migration) — matches old config

      # Work Mac: personal daily tools + work (cloud/k8s) tooling.
      zix.profiles.personal.enable = true;
      zix.profiles.work.enable = true;

      # Claude and herdr both write to settings.json, so it cannot live in the
      # store — an immutable copy makes every such write fail. Only this dotfile
      # is mutable here; the rest stay in-store.
      zix.dotfiles.path = config.profile.checkoutPath;
      zix.dotfiles.mutable.claude-settings = true;
    };
}
