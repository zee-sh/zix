{
  # Core cross-platform CLI packages. Kept minimal; grow as needed. Some of these
  # will later become proper home-manager program modules (bat, fzf, …).
  flake.modules.homeManager.packages =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf osConfig.zix.packages.enable {
        home.packages = with pkgs; [
          # core CLI
          bat
          comma
          delta
          fd
          fzf
          git
          gh
          gnupg
          go-task
          jq
          just
          lazygit
          pre-commit
          ripgrep
          tmux
          wget
          yq-go # terminal `jq` for YAML
          yt-dlp
          zsh

          # software development
          go
          golangci-lint
          uv
        ];
      };
    };
}
