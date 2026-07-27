{
  # herdr — agent multiplexer. The binary itself comes from Homebrew (see
  # darwin/homebrew.nix); this module owns the config and the personal-session
  # bootstrap so both Macs reconstruct the same working context.
  #
  # herdr sessions are NOT portable between machines: a session is a live server
  # plus PTYs plus child processes on one host, and session.json holds absolute
  # local paths. What is portable is the recipe — this config plus the
  # `herdr-personal` script below.
  flake.modules.homeManager.herdr =
    {
      config,
      osConfig,
      lib,
      pkgs,
      ...
    }:
    let
      home = config.home.homeDirectory;

      # Workspaces the personal session should always have. Add a line here and
      # rerun `herdr-personal` on each Mac; existing workspaces are left alone.
      personalWorkspaces = {
        "zix" = "${home}/projects/personal/zix";
        "agent-sync" = "${home}/projects/personal/agent-sync";
      };

      ensureCalls = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          label: dir: "ensure ${lib.escapeShellArg label} ${lib.escapeShellArg dir}"
        ) personalWorkspaces
      );

      herdr-personal = pkgs.writeShellApplication {
        name = "herdr-personal";
        runtimeInputs = [ pkgs.jq ];
        text = ''
          # Bootstrap the personal herdr session. Idempotent: safe to rerun.
          #   usage: herdr-personal [session-name]   (default: personal)
          session="''${1:-personal}"
          sock="$HOME/.config/herdr/sessions/$session/herdr.sock"

          # --session outranks HERDR_SOCKET_PATH, which outranks HERDR_SESSION.
          # Running inside another session's pane injects HERDR_SOCKET_PATH, so
          # always pass --session explicitly and strip the inherited vars when
          # spawning a server.
          hs() { herdr --session "$session" "$@"; }

          if ! hs workspace list >/dev/null 2>&1; then
            echo "starting herdr session '$session'..."
            nohup env -u HERDR_SOCKET_PATH -u HERDR_CLIENT_SOCKET_PATH -u HERDR_SESSION \
              herdr --session "$session" server >/dev/null 2>&1 &
            for _ in {1..40}; do
              [ -S "$sock" ] && break
              sleep 0.25
            done
            hs workspace list >/dev/null 2>&1 || {
              echo "error: could not reach the '$session' session server" >&2
              echo "hint: check 'herdr status' — a stale server on an older protocol" >&2
              echo "      cannot be driven by a newer CLI." >&2
              exit 1
            }
          fi

          existing="$(hs workspace list | jq -r '.result.workspaces[].label // empty')"

          ensure() {
            label="$1"
            dir="$2"
            if printf '%s\n' "$existing" | grep -qxF "$label"; then
              printf '  = %s\n' "$label"
            elif [ ! -d "$dir" ]; then
              printf '  ! %s (skipped, no such directory: %s)\n' "$label" "$dir"
            else
              hs workspace create --cwd "$dir" --label "$label" --no-focus >/dev/null
              printf '  + %s\n' "$label"
            fi
          }

          ${ensureCalls}

          echo
          if [ "$session" = "personal" ]; then
            echo "attach with:  herdr --session personal    (alias: hp)"
          else
            echo "attach with:  herdr --session $session"
          fi
        '';
      };
    in
    {
      config = lib.mkIf osConfig.zix.herdr.enable {
        xdg.configFile."herdr/config.toml".source = ./herdr-config.toml;

        home.packages = [ herdr-personal ];

        home.shellAliases = {
          hw = "herdr"; # work / default session
          hp = "herdr --session personal";
        };
      };
    };
}
