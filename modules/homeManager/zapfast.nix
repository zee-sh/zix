{ inputs, ... }:
{
  # ZapFast (WhatsApp desktop client) via its own flake's home-manager module,
  # which also manages settings.json declaratively. The flake builds + self-signs
  # the aarch64-darwin .app (mic entitlements), so unlike a nix-hostile app this
  # needs no brew cask. The input is public, so this lives in the base catalogue
  # (CI can fetch it); the build only happens on `switch` when the toggle is on.
  flake.modules.homeManager.zapfast =
    { lib, osConfig, ... }:
    {
      imports = [ inputs.zapfast.homeManagerModules.default ];

      config = lib.mkIf osConfig.zix.zapfast.enable {
        programs.zapfast = {
          enable = true;
          # Match the repo's no-self-updater stance (see darwin/homebrew.nix):
          # declared keys are reset to these on each activation.
          settings.check_for_updates = false;
        };
      };
    };
}
