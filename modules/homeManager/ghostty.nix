{
  # Ghostty terminal config. The app itself is installed via the Homebrew cask
  # (see darwin/homebrew.nix); this just manages its config. Ghostty reads
  # ~/.config/ghostty/config on macOS (XDG).
  flake.modules.homeManager.ghostty =
    { osConfig, lib, ... }:
    {
      config = lib.mkIf osConfig.zix.ghostty.enable {
        xdg.configFile."ghostty/config".source = ./ghostty-config;
      };
    };
}
