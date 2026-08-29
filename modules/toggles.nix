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
      neovim.enable = lib.mkEnableOption "neovim (nix-wrapper-modules; plugins + LSPs from nix)";
      herdr.enable = lib.mkEnableOption "herdr config + personal session bootstrap";
      aliases.enable = lib.mkEnableOption "shared shell aliases";
      packages.enable = lib.mkEnableOption "core CLI nix packages";
      cloud.enable = lib.mkEnableOption "cloud/k8s/IaC/DevSecOps tooling (work)";
      homebrew.enable = lib.mkEnableOption "Homebrew (nix-homebrew) + casks/brews";
      changesReport.enable = lib.mkEnableOption "print what changed (nvd diff) on each activation";

      # Mode (not a feature): edit managed dotfiles live without a rebuild.
      # Per-dotfile: zix.dotfiles.mutable.<name> = true;  global: mutableByDefault.
      dotfiles.mutableByDefault = lib.mkEnableOption "making all managed dotfiles editable (out-of-store)";
      dotfiles.mutable = lib.mkOption {
        type = lib.types.attrsOf lib.types.bool;
        default = { };
        example = {
          zellij = true;
          ghostty = false;
        };
        description = ''
          Per-dotfile mutability, keyed by the name passed to dotfiles.make
          (e.g. "zellij", "ghostty", "nushell"). Overrides mutableByDefault.
        '';
      };
      dotfiles.path = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "/Users/you/projects/personal/zix";
        description = ''
          Absolute path to your live zix checkout on this machine. Required when any
          dotfile is mutable (mkOutOfStoreSymlink needs it); set it in the host.
        '';
      };
    };
  };
}
