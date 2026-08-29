{
  # Claude Code's status line (shells out to starship, so it matches the prompt)
  # and settings.json. Keep settings.json MUTABLE: Claude and herdr both write to
  # it, and an immutable host makes every such write fail.
  #
  # User settings are the WEAKEST layer and merge with project ones, so keep this
  # file to stable globals. Denies belong here (deny is absolute at every layer);
  # per-project allows belong in that repo's .claude/settings.json.
  flake.modules.homeManager.claude =
    {
      config,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf osConfig.zix.claude.enable {
        # No `executable = true`: home-manager copies rather than symlinks files
        # needing an exec bit, and it cannot read the out-of-store source.
        # Not needed anyway — settings.json runs this via `bash`.
        home.file.".claude/statusline-command.sh".source =
          config.dotfiles.make "claude-statusline" "modules/homeManager/_claude/statusline-command.sh";

        home.file.".claude/settings.json".source =
          config.dotfiles.make "claude-settings" "modules/homeManager/_claude/settings.json";

        # Claude Code is not a nix package; its installer drops `claude` in
        # ~/.local/bin and patches ~/.zshrc, which home-manager owns and
        # overwrites. Without this, fresh shells get "command not found".
        home.sessionPath = [ "$HOME/.local/bin" ];
      };
    };
}
