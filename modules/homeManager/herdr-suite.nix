{ inputs, ... }:
{
  # Own herdr extensions (github.com/zee-sh/herdr-suite): plugins linked into the
  # herdr TUI on activation; mods, layouts and keys copied into ~/.config/herdr-app.
  # The app's settings live here as a mutable dotfile: the app writes them.
  flake.modules.homeManager.herdrSuite =
    {
      config,
      osConfig,
      lib,
      ...
    }:
    let
      work = osConfig.zix.profiles.work.enable;
      appFile = rel: config.dotfiles.make "herdr-app" "modules/homeManager/_herdr-app/${rel}";
    in
    {
      imports = [ inputs.herdr-suite.homeManagerModules.default ];

      config = lib.mkIf osConfig.zix.herdrSuite.enable {
        programs.herdr-suite = {
          auto-rename.enable = true;
          drawer.enable = true;
          space-agents = {
            enable = true;
            idColor = "blue";
            tui.keys = {
              next-space = "prefix+]";
              prev-space = "prefix+[";
            };
          };
          session-links.enable = true;
          iac-board.enable = work;
          # Start URL and region: by hand in its config.local on the work Mac, not here.
          sso-status.enable = work;
          # my-main(-herdr).json and their keys, made for what's on above.
          app.layout = {
            enable = true;
            name = "my-main";
          };
          app.keys.extra.global."cmd-shift-e" = "layout.toggle:panel";
          # Refresh the Claude status hook on each switch. settings.json is linked
          # into this repo (claude.nix) and already runs the hook: keep it as is.
          tui.integrations = [
            {
              name = "claude";
              keep = [ "${config.home.homeDirectory}/.claude/settings.json" ];
            }
          ]
          ++ lib.optional work {
            name = "claude";
            env.CLAUDE_CONFIG_DIR = "${config.home.homeDirectory}/.claude-work";
          };
        };

        home.file.".config/herdr-app/settings.json".source = appFile "settings.json";
      };
    };
}
