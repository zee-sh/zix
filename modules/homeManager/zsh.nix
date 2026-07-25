{
  # zsh — the primary shell. Uses home-manager's built-in autosuggestion,
  # syntax highlighting, and history-substring-search (instead of manually
  # fetching those plugins). Shell aliases come from the aliases feature.
  flake.modules.homeManager.zsh =
    {
      config,
      osConfig,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf osConfig.zix.zsh.enable {
        programs.zsh = {
          enable = true;
          dotDir = "${config.xdg.configHome}/zsh";
          enableCompletion = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          historySubstringSearch.enable = true;

          dirHashes = {
            config = "$HOME/.config";
            desk = "$HOME/Desktop";
            zix = "$HOME/projects/personal/zix";
          };

          envExtra = ''
            export DISABLE_TELEMETRY="true"
            alias assume="source assume"
            export GRANTED_ALIAS_CONFIGURED="true"
            fpath=(${config.home.homeDirectory}/.granted/zsh_autocomplete/assume/ $fpath)
            fpath=(${config.home.homeDirectory}/.granted/zsh_autocomplete/granted/ $fpath)
          '';

          initContent = lib.mkMerge [
            (lib.mkBefore ''
              eval "$(/opt/homebrew/bin/brew shellenv)"
            '')
            ''
              # Only wire these if the tools are present (avoids startup errors).
              if command -v kubectl &>/dev/null; then
                alias k=kubectl
                source <(kubectl completion zsh)
                compdef k='kubectl'
              fi
              if command -v switch &>/dev/null; then
                source <(switcher init zsh)
                source <(switch completion zsh)
              fi

              HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=yellow,fg=black,bold"
              HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND="bg=red,fg=black,bold"

              # Completion
              zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
              # fzf-tab
              zstyle ':completion:*:git-checkout:*' sort false
              zstyle ':completion:*:descriptions' format '[%d]'
              zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
              zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons -a --group-directories-first --git --color=always $realpath'
              zstyle ':fzf-tab:*' switch-group ',' '.'

              # shift-tab: reverse menu completion
              bindkey '^[[Z' reverse-menu-complete

              # navigate to a config subdir
              config() {
                cd "$XDG_CONFIG_HOME/$1" || echo "$1 is not a valid config directory."
              }
            ''
          ];

          history = {
            expireDuplicatesFirst = true;
            extended = true;
            ignoreDups = true;
            ignoreSpace = true;
            save = 100000;
            size = 100000;
            share = true;
            path = "${config.xdg.configHome}/zsh/history";
          };

          plugins = [
            {
              name = "fzf-tab";
              file = "fzf-tab.zsh";
              src = pkgs.fetchgit {
                url = "https://github.com/Aloxaf/fzf-tab";
                sha256 = "sha256-zc9Sc1WQIbJ132hw73oiS1ExvxCRHagi6vMkCLd4ZhI=";
              };
            }
            {
              name = "zsh-notify";
              file = "auto-notify.plugin.zsh";
              src = pkgs.fetchgit {
                url = "https://github.com/MichaelAquilina/zsh-auto-notify";
                sha256 = "sha256-s3TBAsXOpmiXMAQkbaS5de0t0hNC1EzUUb0ZG+p9keE=";
              };
            }
            {
              name = "ssh-completion";
              file = "zsh-ssh.zsh";
              src = pkgs.fetchgit {
                url = "https://github.com/sunlei/zsh-ssh";
                sha256 = "sha256-lc3fRcM1IazuDRvlOmPEiHk5ddWalqsiNNKcOj8eUSs=";
              };
            }
            {
              name = "zsh-sudo";
              file = "plugins/sudo/sudo.plugin.zsh";
              src = pkgs.fetchgit {
                url = "https://github.com/ohmyzsh/ohmyzsh";
                sha256 = "sha256-2EEoYU3uyHd/fT8SWnj79O/I9G+ULh2xYj0p46Mh904=";
                sparseCheckout = [ "plugins/sudo" ];
              };
            }
            {
              name = "you-should-use";
              src = pkgs.fetchFromGitHub {
                owner = "MichaelAquilina";
                repo = "zsh-you-should-use";
                rev = "1.7.3";
                sha256 = "/uVFyplnlg9mETMi7myIndO6IG7Wr9M7xDFfY1pG5Lc=";
              };
            }
          ];
        };
      };
    };
}
