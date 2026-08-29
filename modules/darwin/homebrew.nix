{ inputs, ... }:
{
  # Homebrew, bootstrapped + owned by nix-homebrew (installs brew on a fresh box),
  # with casks/brews declared via nix-darwin's homebrew module. mutableTaps stays
  # true so third-party taps can be added later without pinning them as inputs.
  #
  # Base (personal) config gates on zix.homebrew.enable; work taps/brews gate on
  # zix.profiles.work.enable and merge into the same lists.
  #
  # Commented entries are available (from the old nix-config) — uncomment to enable.
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

            # trusted required: Homebrew aborts on untrusted third-party taps during
            # `brew bundle`, and nix-darwin defaults taps to trusted = false.
            taps = [
              {
                name = "danielfoehrkn/switch";
                trusted = true;
              } # kubeswitch
              {
                name = "Azure/kubelogin";
                trusted = true;
              } # kubelogin
              {
                name = "agavra/tap";
                trusted = true;
              } # tuicr
            ];

            brews = [
              # shell / cli
              "coreutils" # https://www.gnu.org/software/coreutils/ - GNU file, shell & text utilities
              "ffmpeg" # https://ffmpeg.org/ - play, record, convert & stream audio/video
              # editor
              # "neovim" # now from nix (zix.neovim) — brew's bin would shadow it on PATH
              # cloud / k8s auth
              "granted" # https://granted.dev/ - the easiest way to access your cloud
              "danielfoehrkn/switch/switch" # https://github.com/danielfoehrKn/kubeswitch - the kubectx for operators
              "Azure/kubelogin/kubelogin" # https://github.com/Azure/kubelogin - Azure auth (exec) plugin for kubectl
              # agent tooling
              "herdr" # https://herdr.dev - agent multiplexer for the terminal
              # rtk is in nixpkgs but 0.43.0 there fails to build (-D warnings vs dead
              # code in its test target); brew ships a newer bottled release.
              "rtk" # https://github.com/rtk-ai/rtk - CLI proxy that compresses command output for LLM agents
              "hunk" # https://hunk.dev/ - review-first terminal diff viewer
              "agavra/tap/tuicr" # https://github.com/agavra/tuicr - terminal UI for code reviews
            ];

            casks = [
              # Browsers
              "brave-browser" # https://brave.com/ - privacy-focused web browser
              "firefox" # https://www.mozilla.org/firefox/ - web browser
              "google-chrome" # https://www.google.com/chrome/ - web browser

              # Terminals
              "ghostty" # https://ghostty.org/ - native, GPU-accelerated terminal
              # "wezterm" # https://wezterm.org/ - GPU terminal + multiplexer

              # Editors / IDE
              # "cursor" # https://www.cursor.com/ - AI code editor
              # "visual-studio-code" # https://code.visualstudio.com/ - code editor

              # Kubernetes / DevOps
              "aptakube" # https://aptakube.com/ - Kubernetes desktop client
              "headlamp" # https://headlamp.dev/ - Kubernetes UI

              # Productivity / notes
              "todoist-app" # https://todoist.com/ - to-do list
              "drawio" # https://www.diagrams.net/ - diagram software
              # "obsidian" # https://obsidian.md/ - Markdown knowledge base
              # "linear" # https://linear.app/ - issue tracking
              # "morgen" # https://morgen.so/ - calendar, tasks & scheduler
              # "antinote" # https://antinote.io/ - quick notes with calculations
              # "reader" # https://readwise.io/read/ - read-later (Readwise Reader)
              # "soulver-cli" # https://github.com/soulverteam/Soulver-CLI - Soulver calculation engine CLI

              # Window mgmt / input
              # "aerospace" # https://github.com/nikitabobko/AeroSpace - i3-like tiling WM for macOS
              # "alt-tab" # https://alt-tab.app/ - Windows-like alt-tab
              # "hammerspoon" # https://www.hammerspoon.org/ - desktop automation
              # "jordanbaird-ice" # https://icemenubar.app/ - menu bar manager (Ice)
              # "linearmouse" # https://linearmouse.org/ - mouse customization

              # Media
              "iina" # https://iina.io/ - open-source media player

              # Utilities
              "raycast" # https://raycast.com/ - launcher / productivity
              "setapp" # https://setapp.com/ - subscription app collection
              "lookaway" # https://lookaway.com/ - break-time reminder
              "betterdisplay" # https://betterdisplay.pro/ - display management
              "balenaetcher" # https://balena.io/etcher - flash OS images to SD/USB
              # "appcleaner" # https://freemacsoft.net/appcleaner/ - app uninstaller
              # "hazel" # https://www.noodlesoft.com/ - automated file organization
              # "shottr" # https://shottr.cc/ - screenshot & annotation
              # "flux-app" # https://justgetflux.com/ - screen colour temperature
              # "blurred" # https://github.com/dwarvesf/blurred/ - dim inactive windows
              # "processspy" # https://process-spy.app/ - process monitor

              # Security / privacy
              "1password" # https://1password.com/ - password manager
              "lulu" # https://objective-see.org/products/lulu.html - open-source outbound firewall
              # "little-snitch" # https://www.obdev.at/products/littlesnitch/index.html - application firewall
              # "micro-snitch" # https://www.obdev.at/products/microsnitch/index.html - mic/camera activity monitor

              # Comms
              "slack" # https://slack.com/ - team chat
              "whatsapp" # https://www.whatsapp.com/ - WhatsApp desktop
              # "discord" # https://discord.com/ - voice/text chat

              # Sync / VM
              # "syncthing-app" # https://syncthing.net/ - file synchronization
              # "utm" # https://mac.getutm.app/ - virtual machines (QEMU)
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
              } # nova, pluto
              {
                name = "pulumi/tap";
                trusted = true;
              } # esc
              {
                name = "turbot/tap";
                trusted = true;
              } # powerpipe
              {
                name = "surrealdb/tap";
                trusted = true;
              } # surreal
              {
                name = "xataio/pgstream";
                trusted = true;
              } # pgstream
            ];

            brews = [
              # cloud / IaC
              "opentofu" # https://opentofu.org/ - Terraform-compatible IaC tool
              "pulumi" # https://www.pulumi.com/ - cloud-native IaC platform
              "pulumi/tap/esc" # https://www.pulumi.com/product/esc/ - Pulumi ESC (environments/secrets/config)
              "cloud-nuke" # https://gruntwork.io/ - nuke (delete) cloud resources
              # kubernetes
              "clusterctl" # https://cluster-api.sigs.k8s.io - Cluster API management CLI
              "clusterawsadm" # https://cluster-api-aws.sigs.k8s.io - Cluster API AWS provider helper
              "kubectl-ai" # https://github.com/GoogleCloudPlatform/kubectl-ai - AI-powered Kubernetes assistant
              "fairwindsops/tap/nova" # https://github.com/FairwindsOps/nova - check installed Helm charts for updates
              "fairwindsops/tap/pluto" # https://github.com/FairwindsOps/pluto - detect deprecated Kubernetes apiVersions
              "turbot/tap/powerpipe" # https://powerpipe.io/ - DevOps dashboards & benchmarks
              # databases
              "duckdb" # https://www.duckdb.org - embeddable SQL OLAP database
              "postgresql@16" # https://www.postgresql.org/ - object-relational database
              "pgstream" # https://www.xata.io - PostgreSQL replication with DDL changes
              "surrealdb/tap/surreal" # https://surrealdb.com - distributed document-graph database
              # languages / misc
              "python@3.12" # https://www.python.org/ - Python interpreter
              "m-cli" # https://github.com/rgcr/m-cli - Swiss Army knife for macOS
              "mas" # https://github.com/mas-cli/mas - Mac App Store CLI
              "cowsay" # https://cowsay.diamonds - classic cowsay
            ];
          };
        })
      ];
    };
}
