{
  # nushell (secondary shell). atuin/zoxide/starship wire their nushell
  # integrations automatically when those features are also enabled.
  flake.modules.homeManager.nushell =
    { osConfig, lib, ... }:
    {
      config = lib.mkIf osConfig.zix.nushell.enable {
        programs.nushell = {
          enable = true;
          envFile.source = ./nushell-env.nu;
          configFile.source = ./nushell-config.nu;
        };
      };
    };
}
