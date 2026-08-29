{
  # Shared shell aliases (apply to all HM-managed shells, i.e. zsh here).
  # git aliases live in git.nix; these are the interactive shell shortcuts.
  flake.modules.homeManager.aliases =
    { osConfig, lib, ... }:
    {
      config = lib.mkIf osConfig.zix.aliases.enable {
        home.shellAliases = {
          # General
          cd = "z";
          lg = "lazygit";
          g = "git ";
          ga = "git add";
          gba = "git branch -a";
          gbd = "git branch -D";
          gb = "git branch";
          gciam = "git commit -am";
          gco = "git checkout";
          gcob = "git checkout -b";
          gci = "git commit";
          gcim = "git commit -m";
          gcp = "git commit -p";
          gcrp = "git cherry-pick";
          gd = "git diff";
          gdco = "git commit --amend --no-edit --signoff";
          gs = "git status --short";
          gpr = "git pull --rebase";
          gph = "git push";
          gphf = "git push --force-with-lease";
          gst = "git status";
          gl = "git log --graph --pretty='%Cred%h%Creset - %C(bold blue)<%an>%Creset %s%C(yellow)%d%Creset %Cgreen(%cr)' --abbrev-commit --date=relative";
          gl2 = "git log --graph --decorate=short --date=short --pretty=format:'%C(yellow)%h%C(reset) %C(blue)%ad%C(reset) %C(green)%an%C(reset) %s %C(red)%d%C(reset)'";
          gwhoops = "reset --hard";
          gcm = "git checkout main";
          gds = "git diff --staged";

          t = "task";
          tl = "task --list-all";

          l = "eza -l --icons --git -a";
          ltr = "eza -lh --tree --git --icons=auto";

          v = "nvim";
          fzp = "fzf -m --preview 'bat --style=numbers --color=always {}'";
          vinv = "v $(fzp)";
          f = "open .";
          cl = "clear";

          # Dirs
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          "....." = "cd ../../../..";
          "--" = "cd -";

          # Network
          ip = "dig +short myip.opendns.com @resolver1.opendns.com";
          localip = "ipconfig getifaddr en0";
          copyssh = "pbcopy < $HOME/.ssh/id_ed25519.pub";
          addssh = "ssh-add ~/.ssh/id_ed25519 --apple-use-keychain --apple-load-keychain";
          flushd = "dscacheutil -flushcache && killall -HUP mDNSResponder";

          # Hide/show desktop icons (presenting)
          hidedesktop = "defaults write com.apple.finder CreateDesktop -bool false && killall Finder";
          showdesktop = "defaults write com.apple.finder CreateDesktop -bool true && killall Finder";

          diff = "diff --color=auto";
          grep = "grep --color=auto";
          szsh = "source ~/.zshrc";

          # IaC
          tf = "terraform";
          pl = "pulumi";
          plp = "pulumi preview";
          plpd = "pulumi preview --diff";
          plu = "pulumi up --suppress-outputs";

          # AWS
          aid = "aws sts get-caller-identity --query Account --output text";
          asl = "aws sso login";

          # kubectl / k8s
          k = "kubectl";
          kx = "switch";
          kns = "kubens";
          ka = "kubectl apply -f";
          kg = "kubectl get";
          kd = "kubectl describe";
          kdel = "kubectl delete";
          kgy = "kubectl get -o=yaml";
          ke = "kubectl exec -it";
          kga = "kubectl get all";
          kgaa = "kubectl get all --all-namespaces";
          kgp = "kubectl get pod";
          kgpa = "kubectl get pods --all-namespaces";
          kdp = "kubectl describe pods";
          kdelp = "kubectl delete pods";
          kgd = "kubectl get deployment";
          ked = "kubectl edit deployment";
          kdd = "kubectl describe deployment";
          kdeld = "kubectl delete deployment";
          kgs = "kubectl get service";
          kes = "kubectl edit svc";
          kds = "kubectl describe svc";
          kgns = "kubectl get namespaces";
          kcn = "kubectl config set-context --current --namespace";
          kgsec = "kubectl get secret";
          kgn = "kubectl get nodes";
          kdn = "kubectl describe nodes";
          kl = "kubectl logs";
          klf = "kubectl logs -f";
          ksys = "kubectl --namespace=kube-system";
          cil = "cilium";

          # direnv
          da = "direnv allow";
          dr = "direnv reload";
          dk = "direnv revoke";

          yt = "yt-dlp";

          # Nix
          xn = "sudo nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake .";
          xx = "sudo darwin-rebuild switch --flake .";
          ngc = "nix store gc -v";
          ndev = "nix develop";
          nfc = "nix flake check";
          nfs = "nix flake show";
          nfu = "nix flake update";
          nsn = "nix search nixpkgs";

          # processes
          pf = "pgrep -f";
        };
      };
    };
}
