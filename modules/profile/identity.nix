{
  # FORKED THIS REPO? THIS IS THE ONLY FILE YOU MUST EDIT.
  # Everything reads from here: git identity, the primary account, and the
  # checkout path that mutable dotfiles symlink into.
  flake.modules.generic.profile =
    { lib, ... }:
    {
      options.profile = lib.mkOption {
        readOnly = true;
        type = lib.types.submodule {
          options = {
            username = lib.mkOption {
              type = lib.types.str;
              description = "macOS account name; must match an existing local account.";
            };
            fullName = lib.mkOption {
              type = lib.types.str;
              description = "Git author name.";
            };
            email = lib.mkOption {
              type = lib.types.str;
              description = "Git author email.";
            };
            checkoutPath = lib.mkOption {
              type = lib.types.str;
              description = ''
                Absolute path to this checkout. mkOutOfStoreSymlink needs it literally
                at eval time, so it cannot be derived. A wrong value gives dangling
                symlinks rather than a build error.
              '';
            };
          };
        };
      };

      config.profile = {
        username = "zeeshans";
        fullName = "Zeeshan Sanaullah";
        email = "2057695+zee-sh@users.noreply.github.com";
        checkoutPath = "/Users/zeeshans/projects/personal/zix";
      };
    };
}
