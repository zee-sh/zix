{
  # git + delta + gh + lazygit. Identity comes from the system `profile`
  # (osConfig.profile), so it stays in one place.
  flake.modules.homeManager.git =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf osConfig.zix.git.enable {
        programs.git = {
          enable = true;
          ignores = lib.splitString "\n" (builtins.readFile ./gitignore_global);
          lfs.enable = true;

          settings = {
            user.name = osConfig.profile.fullName;
            user.email = osConfig.profile.email;

            alias = {
              ba = "branch -a";
              bd = "branch -D";
              br = "branch";
              cam = "commit -am";
              co = "checkout";
              cob = "checkout -b";
              ci = "commit";
              cm = "commit -m";
              cp = "commit -p";
              crp = "cherry-pick";
              d = "diff";
              dco = "commit --amend --no-edit --signoff";
              s = "status --short";
              pr = "pull --rebase";
              st = "status";
              l = "log --graph --pretty='%Cred%h%Creset - %C(bold blue)<%an>%Creset %s%C(yellow)%d%Creset %Cgreen(%cr)' --abbrev-commit --date=relative";
              whoops = "reset --hard";
              wipe = "commit -s";
            };

            diff.colorMoved = "default";
            pull.rebase = true;
            init.defaultBranch = "main";
            gpg.format = "ssh";
            core.editor = "nvim";
            core.whitespace = "trailing-space";
            branch.sort = "-committerdate";
            commit.verbose = true;
            column.ui = "auto";
            status.branch = true;
            credential.helper =
              if pkgs.stdenvNoCC.isDarwin then "osxkeychain" else "cache --timeout=1000000000";
          };
        };

        # Enhanced diffs.
        programs.delta = {
          enable = true;
          enableGitIntegration = true;
          options = {
            syntax-theme = "Dracula";
            features = "side-by-side line-numbers decorations";
            decorations = "commit-decoration file-style";
            commit-decoration-style = "blue box ul";
            file-style = "blue ul";
            navigate = true;
            light = false;
            line-numbers = true;
            side-by-side = true;
          };
        };

        programs.gh = {
          enable = true;
          settings = {
            git_protocol = "ssh";
            editor = "nvim";
          };
        };

        programs.lazygit.enable = true;
      };
    };
}
