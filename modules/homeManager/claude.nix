{
  # Claude Code's status line. The script shells out to `starship prompt` and
  # `starship prompt --right` and appends session state (model, context, cost,
  # rate limits, PR link), so the shell prompt and Claude's status bar stay in
  # sync from one starship config — see modules/homeManager/starship.nix.
  #
  # Its dependencies all come from zix already: starship, jq (packages), git and
  # gh (git). Nothing here is machine-specific and the script holds no secrets.
  #
  # settings.json is managed here too, which means agent-sync must stop syncing it
  # — two owners writing one file will fight.
  #
  # The committed copy keeps only the hooks we own: `rtk hook claude` (PreToolUse)
  # and herdr's SessionStart. Hooks injected by third-party tools are deliberately
  # left out — they re-add themselves on machines where those tools are installed,
  # and each one is self-guarding, so it no-ops where they are not.
  #
  # Caveat worth knowing: settings.json is not a hand-authored file. Claude writes
  # to it (/config, permission grants) and those tools rewrite it on update. So keep
  # this dotfile MUTABLE on any host you actually work on — an out-of-store symlink
  # lets those writes land in the checkout, where you review and commit them. On an
  # immutable host the file is read-only and every such write fails.
  #   zix.dotfiles.mutable.claude-settings = true;   # plus zix.dotfiles.path
  # m2air gets this via mutableByDefault.
  flake.modules.homeManager.claude =
    {
      config,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf osConfig.zix.claude.enable {
        home.file.".claude/statusline-command.sh" = {
          source = config.dotfiles.make "claude-statusline" "modules/homeManager/_claude/statusline-command.sh";
          executable = true;
        };

        home.file.".claude/settings.json".source =
          config.dotfiles.make "claude-settings" "modules/homeManager/_claude/settings.json";
      };
    };
}
