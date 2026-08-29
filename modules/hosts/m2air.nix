{ config, ... }:
let
  inherit (config.flake.modules) darwin;
in
{
  # A host picks a preset and overrides. Identity comes from profile/identity.nix,
  # so adopting this repo means editing that file, not every host.
  configurations.darwin."m2air".module =
    { config, ... }:
    {
      imports = [ darwin.base ];

      primaryUser = config.profile.username;
      system.stateVersion = 7; # verify against pinned nix-darwin at first build

      # Compose the host by flipping toggles:
      zix.profiles.personal.enable = true;
      # per-feature overrides go here, e.g. zix.docker.enable = false;

      # Edit managed dotfiles (zellij/ghostty/nushell/herdr) live, no rebuild.
      zix.dotfiles.mutableByDefault = true;
      zix.dotfiles.path = config.profile.checkoutPath;
    };
}
