{ inputs, ... }:
{
  # Homebrew, bootstrapped + owned by nix-homebrew (installs brew on a fresh box),
  # with casks/brews declared via nix-darwin's homebrew module. mutableTaps stays
  # true so third-party taps can be added later without pinning them as inputs.
  #
  # Base (personal) config gates on zix.homebrew.enable; work taps/brews gate on
  # zix.profiles.work.enable and merge into the same lists.
  flake.modules.darwin.homebrew =
    { config, lib, ... }:
    {
      imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

      config = lib.mkMerge [
        # ---- base ----
        (lib.mkIf config.zix.homebrew.enable {
          nix-homebrew = {
            enable = true;
            user = config.primaryUser;
            # Adopt an existing hand-installed /opt/homebrew (e.g. on m4max) instead
            # of erroring; no-op where nix-homebrew already owns it.
            autoMigrate = true;
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
              {
                name = "Azure/kubelogin";
                trusted = true;
              }
            ];

            brews = [
              "granted"
              "coreutils"
              "neovim"
              "ffmpeg"
              "herdr"
              "hunk"
              "danielfoehrkn/switch/switch"
              "Azure/kubelogin/kubelogin"
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
        })

        # ---- work (merges into the lists above) ----
        (lib.mkIf config.zix.profiles.work.enable {
          homebrew = {
            taps = [
              {
                name = "fairwindsops/tap";
                trusted = true;
              }
              {
                name = "pulumi/tap";
                trusted = true;
              }
              {
                name = "turbot/tap";
                trusted = true;
              }
              {
                name = "surrealdb/tap";
                trusted = true;
              }
              {
                name = "xataio/pgstream";
                trusted = true;
              }
            ];

            brews = [
              "cloud-nuke"
              "clusterctl"
              "clusterawsadm"
              "cowsay"
              "duckdb"
              "kubectl-ai"
              "m-cli"
              "mas"
              "opentofu"
              "pgstream"
              "pulumi"
              "python@3.12"
              "postgresql@16"
              "rtk"
              "fairwindsops/tap/nova"
              "fairwindsops/tap/pluto"
              "pulumi/tap/esc"
              "turbot/tap/powerpipe"
              "surrealdb/tap/surreal"
            ];
          };
        })
      ];
    };
}
