{
  # nushell (secondary shell). atuin/zoxide/starship wire their nushell
  # integrations automatically when those features are also enabled.
  flake.modules.homeManager.nushell =
    { config, osConfig, lib, ... }:
    {
      config = lib.mkIf osConfig.zix.nushell.enable {
        programs.nushell = {
          enable = true;
          envFile.source = config.dotfiles.make "nushell" "modules/homeManager/nushell-env.nu";
          configFile.source = config.dotfiles.make "nushell" "modules/homeManager/nushell-config.nu";
        };
      };
    };
}
