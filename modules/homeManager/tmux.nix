{
  flake.modules.homeManager.tmux =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf osConfig.zix.tmux.enable {
        programs.tmux = {
          enable = true;
          clock24 = true;
          escapeTime = 0;
          mouse = true;
          baseIndex = 1;
          terminal = "screen-256color";
          historyLimit = 100000;
          plugins = with pkgs.tmuxPlugins; [
            {
              plugin = catppuccin;
              extraConfig = ''
                set -g @catppuccin_flavour 'macchiato'

                set -g @catppuccin_window_left_separator ""
                set -g @catppuccin_window_right_separator " "
                set -g @catppuccin_window_middle_separator " █"
                set -g @catppuccin_window_number_position "right"

                set -g @catppuccin_window_default_fill "number"
                set -g @catppuccin_window_default_text "#W"

                set -g @catppuccin_window_current_fill "number"
                set -g @catppuccin_window_current_text "#W"

                set -g @catppuccin_status_modules_right "directory session"
                set -g @catppuccin_status_left_separator  " "
                set -g @catppuccin_status_right_separator ""
                set -g @catppuccin_status_right_separator_inverse "no"
                set -g @catppuccin_status_fill "icon"
                set -g @catppuccin_status_connect_separator "no"

                set -g @catppuccin_directory_text "#{pane_current_path}"
              '';
            }
            {
              plugin = resurrect;
              extraConfig = ''
                set -g @resurrect-strategy-nvim 'session'
                set -g @resurrect-capture-pane-contents 'on'
                set -g @resurrect-pane-contents-area 'visible'
              '';
            }
            {
              plugin = continuum;
              extraConfig = ''
                set -g @continuum-restore 'on'
                set -g @continuum-save-interval '30'
              '';
            }
            {
              plugin = extrakto;
              extraConfig = ''
                set -g @extrakto_clip_tool pbcopy
                set -g @extrakto_editor nvim
                set -g @extrakto_filter_order 'url path line word'
              '';
            }
            vim-tmux-navigator
            yank
            sensible
          ];

          extraConfig = ''
            # Use Home key (caps lock, remapped via BTT) as prefix
            set -g prefix Home
            unbind C-b
            bind-key Home send-prefix

            set -g base-index 1
            set -g pane-base-index 1

            set -g focus-events on
            setw -g automatic-rename on
            set -g set-titles on
            set -g renumber-windows on
            set -g mouse on
            set -g detach-on-destroy off
            set -g set-clipboard on

            set -g pane-active-border-style 'fg=magenta,bg=default'
            set -g pane-border-style 'fg=brightblack,bg=default'
          '';
        };
      };
    };
}
