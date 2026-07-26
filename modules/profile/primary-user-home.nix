{
  # Required, or home-manager won't evaluate. home-manager derives home.username /
  # home.homeDirectory automatically from the users.users entry on darwin.
  flake.modules.generic.primaryUserHome =
    { config, ... }:
    {
      home-manager.users.${config.primaryUser} = {
        home.stateVersion = "25.05"; # HM release baseline (safe/valid; bump deliberately)
      };
    };
}
