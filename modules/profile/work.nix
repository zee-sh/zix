{
  # Work preset (m4max): cloud/k8s/azure/aws/IaC/devsecops toggles land here.
  flake.modules.generic.profileWork =
    { config, lib, ... }:
    {
      config = lib.mkIf config.zix.profiles.work.enable {
        zix = {
          git.enable = lib.mkDefault true;
          # work-specific features added later
        };
      };
    };
}
