{
  flake.modules.homeManager.zellij =
    {
      config,
      osConfig,
      lib,
      ...
    }:
    {
      config = lib.mkIf osConfig.zix.zellij.enable {
        programs.zellij.enable = true;
        xdg.configFile."zellij/config.kdl".source =
          config.dotfiles.make "zellij" "modules/homeManager/zellij-config.kdl";
      };
    };
}
