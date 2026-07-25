{
  # Always-on darwin baseline: Nix/nixpkgs, security, fonts. (macOS UI defaults live
  # in system-preferences.nix; the user lives in users.nix.)
  flake.modules.darwin.systemBase =
    { pkgs, ... }:
    {
      # Determinate Nix owns /etc/nix/nix.conf and the daemon — nix-darwin must NOT
      # manage Nix or activation aborts. Do NOT set `ids.gids.nixbld` either
      # (Determinate uses its own GID and nix-darwin asserts on a mismatch).
      #
      # Garbage collection is handled by determinate-nixd (automatic, battery-aware);
      # no nix.gc timer here. See /etc/determinate/config.json (and README "Maintenance").
      nix.enable = false;

      # With home-manager useGlobalPkgs, this also applies to HM.
      nixpkgs.config.allowUnfree = true;

      # Approve sudo with Touch ID (persists across rebuilds).
      security.pam.services.sudo_local.touchIdAuth = true;

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.nerd-fonts.fira-code
        pkgs.nerd-fonts.sauce-code-pro
        pkgs.nerd-fonts.inconsolata
      ];
    };
}
