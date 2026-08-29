{
  # CLI utilities: atuin, bat, bottom, eza, fzf, zoxide.
  # (direnv is its own feature; fish integrations dropped.)
  flake.modules.homeManager.cli =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf osConfig.zix.cli.enable {
        programs.atuin = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
          flags = [ "--disable-up-arrow" ];
        };

        # Fancy cat replacement.
        programs.bat = {
          enable = true;
          extraPackages = with pkgs.bat-extras; [
            batdiff
            batman
            batgrep
            batwatch
            prettybat
          ];
          config = {
            tabs = "4";
            theme = "Catppuccin Mocha";
          };
          themes."Catppuccin Mocha" = {
            src = pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "bat";
              rev = "d714cc1d358ea51bfc02550dabab693f70cccea0";
              sha256 = "sha256-Q5B4NDrfCIK3UAMs94vdXnR42k4AXCqZz6sRn8bzmf4=";
            };
            file = "themes/Catppuccin Mocha.tmTheme";
          };
        };

        programs.bottom.enable = true;

        # ls replacement.
        programs.eza = {
          enable = true;
          git = true;
          icons = "auto";
          enableZshIntegration = true;
        };

        # Fuzzy finder.
        programs.fzf = {
          enable = true;
          enableZshIntegration = true;
          changeDirWidget = {
            command = "fd --type d --hidden --follow --exclude .git";
            options = [
              "--preview '${lib.getExe pkgs.eza} --oneline --git --long {}'"
            ];
          };
          # Atuin owns Ctrl-R. Its shell integration is sourced after fzf's, so it
          # already won by ordering; setting an empty command makes that explicit
          # and silences home-manager's "both configure Ctrl-R" warning. fzf keeps
          # Ctrl-T (files) and Alt-C (cd). To hand Ctrl-R back to fzf instead, drop
          # this line and add "--disable-ctrl-r" to programs.atuin.flags above.
          historyWidget.command = "";
          historyWidget.options = [ "--sort" ];
          fileWidget = {
            command = "fd --type f --hidden --follow --exclude .git";
            options = [
              "--preview '${lib.getExe pkgs.bat} --color=always --style=numbers --line-range :300 {}'"
            ];
          };
          defaultCommand = "fd --type f --hidden --follow --exclude .git";
          colors = {
            "bg+" = "#293739";
            bg = "#1B1D1E";
            border = "#808080";
            spinner = "#E6DB74";
            hl = "#7E8E91";
            fg = "#F8F8F2";
            header = "#7E8E91";
            info = "#A6E22E";
            pointer = "#A6E22E";
            marker = "#F92672";
            "fg+" = "#F8F8F2";
            prompt = "#F92672";
            "hl+" = "#F92672";
          };
          tmux.enableShellIntegration = true;
        };

        programs.zoxide = {
          enable = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
        };
      };
    };
}
