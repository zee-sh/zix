{
  # direnv with nix-direnv (fast, cached use_nix/use_flake). Shell hooks are wired
  # automatically by programs.direnv for the enabled shells.
  flake.modules.homeManager.direnv =
    { osConfig, lib, ... }:
    {
      config = lib.mkIf osConfig.zix.direnv.enable {
        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
      };
    };
}
