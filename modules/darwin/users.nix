{
  flake.modules.darwin.users =
    { config, ... }:
    {
      users.users.${config.primaryUser} = {
        home = "/Users/${config.primaryUser}";
      };

      # nix-darwin requires a designated primary user for user-scoped defaults.
      system.primaryUser = config.primaryUser;
    };
}
