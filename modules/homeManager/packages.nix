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
            bat # https://github.com/sharkdp/bat - cat clone with syntax highlighting & git
            comma # https://github.com/nix-community/comma - run programs without installing them
            fd # https://github.com/sharkdp/fd - fast, user-friendly find alternative
            fzf # https://github.com/junegunn/fzf - command-line fuzzy finder
            jq # https://jqlang.github.io/jq/ - command-line JSON processor
            yq-go # https://mikefarah.gitbook.io/yq/ - command-line YAML processor
            just # https://github.com/casey/just - project command runner
            ripgrep # https://github.com/BurntSushi/ripgrep - fast recursive grep
            tmux # https://tmux.github.io/ - terminal multiplexer
            wget # https://www.gnu.org/software/wget/ - HTTP/HTTPS/FTP file retriever
            zsh # https://www.zsh.org/ - Z shell
            procs # https://github.com/dalance/procs - modern ps replacement
            duf # https://github.com/muesli/duf - disk usage/free utility
            tldr # https://tldr.sh - simplified, community man pages
            fastfetch # https://github.com/fastfetch-cli/fastfetch - system info tool (neofetch-like)
            gnupg # https://gnupg.org - GNU Privacy Guard (OpenPGP)
            yt-dlp # https://github.com/yt-dlp/yt-dlp - audio/video downloader
            terminal-notifier # https://github.com/julienXX/terminal-notifier - macOS notifications from the CLI (darwin)

            # git
            git # https://git-scm.com/ - distributed version control
            gh # https://cli.github.com/ - GitHub CLI
            lazygit # https://github.com/jesseduffield/lazygit - terminal UI for git
            delta # https://github.com/dandavison/delta - syntax-highlighting pager for git
            diff-so-fancy # https://github.com/so-fancy/diff-so-fancy - good-looking git diffs
            difftastic # https://github.com/Wilfred/difftastic - syntax-aware diff

            # file transfer / manager
            croc # https://github.com/schollz/croc - securely send files between computers
            magic-wormhole # https://magic-wormhole.readthedocs.io/ - securely transfer data between computers
            superfile # https://github.com/yorukot/superfile - modern terminal file manager

            # development
            go # https://go.dev/ - Go programming language
            golangci-lint # https://golangci-lint.run/ - fast Go linters runner
            uv # https://github.com/astral-sh/uv - fast Python package installer/resolver
            devbox # https://www.jetify.com/devbox - instant, predictable dev shells
            bun # https://bun.sh - fast JS runtime, bundler & package manager
            go-task # https://taskfile.dev/ - task runner (simpler Make)
            pre-commit # https://pre-commit.com/ - manage git pre-commit hooks

            # network
            aria2 # https://aria2.github.io - multi-protocol download utility
            bandwhich # https://github.com/imsnif/bandwhich - network utilization by process
            bmon # https://github.com/tgraf/bmon - bandwidth monitor
            curl # https://curl.se/ - transfer files by URL
            curlie # https://github.com/rs/curlie - curl frontend with httpie's UX
            doggo # https://github.com/mr-karan/doggo - command-line DNS client
            gping # https://github.com/orf/gping - ping, but with a graph
            httpie # https://httpie.org/ - human-friendly HTTP client
            ipcalc # https://gitlab.com/ipcalc/ipcalc - IP network calculator
            iperf3 # https://software.es.net/iperf/ - measure IP bandwidth
            mtr # https://www.bitwizard.nl/mtr/ - network diagnostics (traceroute + ping)
            nmap # https://nmap.org - network discovery & security auditing
            tcpflow # https://github.com/simsong/tcpflow - TCP stream extractor
            tcping-go # https://github.com/cloverstd/tcping - ping over TCP instead of ICMP
            tcptraceroute # https://github.com/mct/tcptraceroute - traceroute using TCP packets
            tshark # https://www.wireshark.org - network protocol analyzer (CLI Wireshark)
            speedtest-cli # https://github.com/sivel/speedtest-cli - test bandwidth via speedtest.net
            trippy # https://trippy.cli.rs - network diagnostic tool (mtr-like)
            xh # https://github.com/ducaale/xh - fast HTTP client (httpie-like)
          ];
        })

        # ---- cloud / k8s / IaC / DevSecOps (work) ----
        (lib.mkIf osConfig.zix.cloud.enable {
          home.packages = with pkgs; [
            # cloud
            awscli2 # https://aws.amazon.com/cli/ - manage AWS services
            aws-nuke # https://github.com/ekristen/aws-nuke - remove all resources from an AWS account
            azure-cli # https://github.com/Azure/azure-cli - Azure command-line
            eksctl # https://github.com/eksctl-io/eksctl - CLI for Amazon EKS
            hcloud # https://github.com/hetznercloud/cli - Hetzner Cloud CLI
            steampipe # https://steampipe.io/ - query cloud/APIs with SQL

            # IaC
            crd2pulumi # https://github.com/pulumi/crd2pulumi - typed resources from k8s CRDs
            packer # https://www.packer.io - build machine images

            # DevSecOps
            checkov # https://github.com/bridgecrewio/checkov - static analysis for infrastructure-as-code

            # Kubernetes / Docker
            argocd # https://argo-cd.readthedocs.io/ - GitOps continuous delivery for Kubernetes
            cilium-cli # https://www.cilium.io/ - install/manage/troubleshoot Cilium
            hubble # https://github.com/cilium/hubble - Kubernetes network observability (eBPF)
            k3d # https://github.com/k3d-io/k3d - run k3s in Docker
            k9s # https://github.com/derailed/k9s - Kubernetes TUI
            kind # https://github.com/kubernetes-sigs/kind - Kubernetes in Docker
            krew # https://github.com/kubernetes-sigs/krew - kubectl plugin manager
            kubecolor # https://github.com/kubecolor/kubecolor - colorize kubectl output
            kubectl # https://github.com/kubernetes/kubectl - Kubernetes CLI
            kubectx # https://github.com/ahmetb/kubectx - switch clusters/namespaces
            kubefetch # https://github.com/jkulzer/kubefetch - neofetch-like info for your cluster
            kubernetes-helm # https://github.com/helm/helm - Kubernetes package manager (helm)
            kubetail # https://github.com/johanhaleby/kubetail - tail logs from multiple pods
            kustomize # https://github.com/kubernetes-sigs/kustomize - customize Kubernetes YAML
            lazydocker # https://github.com/jesseduffield/lazydocker - terminal UI for docker
            minikube # https://minikube.sigs.k8s.io - run Kubernetes locally
            popeye # https://github.com/derailed/popeye - cluster resource sanitizer
            stern # https://github.com/stern/stern - multi-pod log tailing
            talosctl # https://www.talos.dev/ - manage Talos Kubernetes nodes
            tilt # https://tilt.dev/ - local Kubernetes dev tool
          ];
        })
      ];
    };
}
