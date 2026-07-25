{ inputs, ... }:
{
  # Homebrew, bootstrapped + owned by nix-homebrew (installs brew on a fresh box),
  # with casks/brews declared via nix-darwin's homebrew module. mutableTaps stays
  # true so third-party taps can be added later without pinning them as inputs.
  flake.modules.darwin.homebrew =
    { config, lib, ... }:
    {
      imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

      config = lib.mkIf config.zix.homebrew.enable {
        nix-homebrew = {
          enable = true;
          user = config.primaryUser;
        };

        homebrew = {
          enable = true;

          onActivation = {
            autoUpdate = true;
            upgrade = true;
            cleanup = "none";
          };

          # Tap for `switch` (granted is in homebrew/core — no tap needed).
          # trusted required: Homebrew aborts on untrusted third-party taps during
          # `brew bundle`, and nix-darwin defaults taps to trusted = false.
          taps = [
            {
              name = "danielfoehrkn/switch";
              trusted = true;
            }
          ];

          brews = [
            "granted"
            "coreutils"
            "neovim"
            "danielfoehrkn/switch/switch"
          ];

          casks = [
            "1password"
            "aptakube"
            "balenaetcher"
            "betterdisplay"
            "brave-browser"
            "drawio"
            "firefox"
            "ghostty"
            "google-chrome"
            "headlamp"
            "iina"
            "lookaway"
            "lulu"
            "raycast"
            "setapp"
            "slack"
            "todoist-app"
            "whatsapp"
          ];

          masApps = { };
        };
      };
    };
}
