{
  flake.modules.homeManager.zellij =
    { osConfig, lib, ... }:
    {
      config = lib.mkIf osConfig.zix.zellij.enable {
        programs.zellij.enable = true;
        xdg.configFile."zellij/config.kdl".source = ./zellij-config.kdl;
      };
    };
}
