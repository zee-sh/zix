{
  # Nix packages. Base set gates on zix.packages.enable; the cloud/work set gates
  # on zix.cloud.enable and merges into home.packages.
  flake.modules.homeManager.packages =
    {
      osConfig,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkMerge [
        # ---- base ----
        (lib.mkIf osConfig.zix.packages.enable {
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

            # network
            aria2
            bandwhich
            bmon
            curl
            curlie
            dog
            gping
            httpie
            ipcalc
            iperf3
            mtr
            nmap
            tcpflow
            tcping-go
            tcptraceroute
            tshark
            speedtest-cli
            trippy
            xh
          ];
        })

        # ---- cloud / k8s / IaC / DevSecOps (work) ----
        (lib.mkIf osConfig.zix.cloud.enable {
          home.packages = with pkgs; [
            # cloud
            awscli2
            aws-nuke
            azure-cli
            eksctl
            hcloud
            steampipe

            # IaC
            crd2pulumi
            packer

            # DevSecOps
            checkov

            # Kubernetes / Docker
            argocd
            cilium-cli
            hubble
            k3d
            k9s
            kind
            krew
            kubecolor
            kubectl
            kubectx
            kubefetch
            kubernetes-helm
            kubetail
            kustomize
            lazydocker
            minikube
            popeye
            stern
            talosctl
            tilt
          ];
        })
      ];
    };
}
