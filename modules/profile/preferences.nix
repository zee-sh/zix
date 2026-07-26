{
  # Identity / appearance — the single source of truth, read by features (e.g. git
  # reads `osConfig.profile.{fullName,email}`). Extend as features need more fields.
  flake.modules.generic.profile =
    { lib, ... }:
    {
      options.profile = lib.mkOption {
        readOnly = true;
        type = lib.types.submodule {
          options = {
            fullName = lib.mkOption { type = lib.types.str; };
            email = lib.mkOption { type = lib.types.str; };
          };
        };
      };

      config.profile = {
        fullName = "Zeeshan Sanaullah";
        email = "2057695+zee-sh@users.noreply.github.com";
      };
    };
}
