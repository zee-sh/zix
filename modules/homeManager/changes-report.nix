{
  # "What changed on switch": on every activation, diff the previous vs new
  # home-manager generation with nvd, so package upgrades/adds/removes are visible
  # instead of a silent switch. Gated by zix.changesReport.enable.
  flake.modules.homeManager.changesReport =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf osConfig.zix.changesReport.enable {
        home.activation.changesReport = lib.hm.dag.entryAnywhere ''
          if [ -e "$oldGenPath" ] && [ "$oldGenPath" != "$newGenPath" ]; then
            ${lib.getExe' pkgs.nvd "nvd"} diff "$oldGenPath" "$newGenPath" || true
          fi
        '';
      };
    };
}
