{ config, ... }:
let
  inherit (config.flake.modules) darwin;
in
{
  configurations.darwin."m2air".module = {
    imports = [ darwin.base ];

    primaryUser = "zeeshans";
    system.stateVersion = 7; # verify against pinned nix-darwin at first build

    # Compose the host by flipping toggles:
    zix.profiles.personal.enable = true;
    # per-feature overrides go here, e.g. zix.docker.enable = false;

    # Edit managed dotfiles (zellij/ghostty/nushell/herdr) live, no rebuild.
    zix.dotfiles.mutableByDefault = true;
    zix.dotfiles.path = "/Users/zeeshans/projects/personal/zix";
  };
}
