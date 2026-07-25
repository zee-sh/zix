{
  # macOS system defaults — the declarative home for "things you'd otherwise click
  # through in System Settings". Always-on (imported by darwin.base). Add settings
  # here instead of changing them by hand.
  #
  # Full list of options: https://mynixos.com/nix-darwin/options/system
  flake.modules.darwin.systemPreferences =
    { config, ... }:
    {
      system.defaults = {
        NSGlobalDomain = {
          # Trackpad: disable natural scrolling.
          "com.apple.swipescrolldirection" = false;

          # Disable press-and-hold (enables key repeat; good for vim j/k).
          ApplePressAndHoldEnabled = false;

          # Turn off the "smart" text substitutions.
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;
        };

        loginwindow = {
          GuestEnabled = false;
          SHOWFULLNAME = false;
        };

        dock = {
          tilesize = 42;
          show-process-indicators = true;
          orientation = "bottom";
          # bottom-left hot corner → Application Windows
          wvous-bl-corner = 3;
        };

        finder = {
          AppleShowAllExtensions = true;
          FXDefaultSearchScope = "SCcf"; # search current folder by default
          FXPreferredViewStyle = "clmv"; # column view
          FXEnableExtensionChangeWarning = false;
          ShowPathbar = true;
          ShowStatusBar = true;
          QuitMenuItem = true;
        };

        screencapture = {
          disable-shadow = true;
          location = "/Users/${config.primaryUser}/Downloads";
        };

        # Raw defaults for domains without first-class nix-darwin options.
        CustomUserPreferences = {
          "com.apple.desktopservices" = {
            # Avoid creating .DS_Store files on network or USB volumes
            DSDontWriteNetworkStores = true;
            DSDontWriteUSBStores = true;
          };
        };
      };
    };
}
