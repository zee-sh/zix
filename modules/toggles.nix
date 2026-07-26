{ lib, ... }:
{
  # The single `zix.*` toggle surface. Declared ONCE at the system (darwin/nixos)
  # level via a `generic` module. Darwin/nixos features read `config.zix.<f>.enable`;
  # home-manager features read `osConfig.zix.<f>.enable` (HM runs as a nix-darwin
  # module, so it sees the system config through `osConfig`).
  #
  # Add a feature toggle here, gate its module's `config` (never its `imports`) with
  # `mkIf`, and enable it from a profile and/or a host.
  flake.modules.generic.toggles = {
    options.zix = {
      profiles = {
        personal.enable = lib.mkEnableOption "the personal profile preset";
        work.enable = lib.mkEnableOption "the work profile preset";
      };

      # Feature toggles (grow this list as features are added).
      git.enable = lib.mkEnableOption "git (delta, gh, lazygit)";
      direnv.enable = lib.mkEnableOption "direnv + nix-direnv";
      cli.enable = lib.mkEnableOption "CLI tools (atuin, bat, bottom, eza, fzf, zoxide)";
      zsh.enable = lib.mkEnableOption "zsh (primary shell)";
      nushell.enable = lib.mkEnableOption "nushell";
      starship.enable = lib.mkEnableOption "starship prompt";
      tmux.enable = lib.mkEnableOption "tmux";
      zellij.enable = lib.mkEnableOption "zellij";
      ghostty.enable = lib.mkEnableOption "ghostty terminal config";
      aliases.enable = lib.mkEnableOption "shared shell aliases";
      packages.enable = lib.mkEnableOption "core CLI nix packages";
      homebrew.enable = lib.mkEnableOption "Homebrew (nix-homebrew) + casks/brews";
    };
  };
}
