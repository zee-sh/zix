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
    };
}
