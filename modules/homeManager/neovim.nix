{ inputs, ... }:
{
  # Neovim via nix-wrapper-modules: nix installs neovim, its plugins and every
  # language server; the config stays real Lua in `_neovim/init.lua`. No Mason and
  # no lazy.nvim downloads at runtime, so this works the same on darwin and NixOS.
  #
  # The spec lives in `_neovim/module.nix` (underscored so import-tree skips it).
  flake.modules.homeManager.neovim =
    { osConfig, lib, ... }:
    let
      wlib = inputs.nix-wrapper-modules.lib;
      wrapperModule = lib.modules.importApply ./_neovim/module.nix inputs;
    in
    {
      imports = [
        (wlib.getInstallModule {
          name = "neovim";
          value = wrapperModule;
        })
      ];

      config = lib.mkIf osConfig.zix.neovim.enable {
        wrappers.neovim.enable = true;
      };
    };
}
