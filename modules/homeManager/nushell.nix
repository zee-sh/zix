{
  # nushell (secondary shell). atuin/zoxide/starship wire their nushell
  # integrations automatically when those features are also enabled.
  flake.modules.homeManager.nushell =
    {
      config,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf osConfig.zix.nushell.enable {
        programs.nushell = {
          enable = true;
          # NOTE: always immutable (not via dotfiles.make). home-manager's nushell
          # module reads these files at eval time, which forbids out-of-store paths
          # in pure mode — so nushell can't participate in zix.dotfiles mutability.
          envFile.source = ./nushell-env.nu;
          configFile.source = ./nushell-config.nu;
        };
      };
    };
}
