{
  # Personal preset: flips a curated batch of feature toggles on. Uses mkDefault so
  # a host can still override any of them to false.
  flake.modules.generic.profilePersonal =
    { config, lib, ... }:
    {
      config = lib.mkIf config.zix.profiles.personal.enable {
        zix = {
          git.enable = lib.mkDefault true;
          direnv.enable = lib.mkDefault true;
          cli.enable = lib.mkDefault true;
          zsh.enable = lib.mkDefault true;
          nushell.enable = lib.mkDefault true;
          starship.enable = lib.mkDefault true;
          tmux.enable = lib.mkDefault true;
          zellij.enable = lib.mkDefault true;
          ghostty.enable = lib.mkDefault true;
          neovim.enable = lib.mkDefault true;
          herdr.enable = lib.mkDefault true;
          aliases.enable = lib.mkDefault true;
          packages.enable = lib.mkDefault true;
          homebrew.enable = lib.mkDefault true;
          changesReport.enable = lib.mkDefault true;
        };
      };
    };
}
