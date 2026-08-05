{ inputs, ... }:
{
  # Mutable-dotfiles helper (adapted from gvolpe's dots pattern).
  #
  # `dotfiles.make "<name>" "<repo-relative-path>"` returns a source for
  # xdg.configFile/home.file:
  #   - immutable (default): an in-store path (reproducible; edits need a rebuild)
  #   - mutable: an out-of-store symlink into the live checkout, so you can edit
  #     the file and see changes WITHOUT a rebuild.
  #
  # Mutability is decided PER dotfile <name>:
  #   zix.dotfiles.mutable.<name> = true;     # just that one
  #   zix.dotfiles.mutableByDefault = true;   # everything, unless overridden
  flake.modules.homeManager.dotfiles =
    {
      config,
      osConfig,
      lib,
      ...
    }:
    let
      cfg = osConfig.zix.dotfiles;
      isMutable = name: cfg.mutable.${name} or cfg.mutableByDefault;
      anyMutable = cfg.mutableByDefault || lib.any (x: x) (lib.attrValues cfg.mutable);
    in
    {
      options.dotfiles.make = lib.mkOption {
        type = lib.types.raw;
        readOnly = true;
        description = ''
          make "<name>" "<repo-relative-path>" -> in-store path (immutable) or an
          out-of-store symlink into zix.dotfiles.path (mutable), decided per <name>.
        '';
      };

      config = {
        # Path is machine-specific; require it only if something is actually mutable.
        assertions = [
          {
            assertion = !anyMutable || cfg.path != "";
            message = ''zix.dotfiles: a dotfile is mutable but zix.dotfiles.path is empty — set it in the host to your checkout (e.g. "/Users/you/projects/personal/zix").'';
          }
        ];

        dotfiles.make =
          name: rel:
          if isMutable name then
            config.lib.file.mkOutOfStoreSymlink "${cfg.path}/${rel}"
          else
            inputs.self + "/${rel}";
      };
    };
}
