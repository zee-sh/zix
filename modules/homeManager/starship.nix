{
  # Starship prompt (inline settings; catppuccin_mocha palette).
  flake.modules.homeManager.starship =
    { osConfig, lib, ... }:
    {
      config = lib.mkIf osConfig.zix.starship.enable {
        programs.starship = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableNushellIntegration = true;
          settings = {
            format = "$directory$character";
            right_format = "\${custom.git_worktree}$git_branch$git_commit$git_state$git_status$kubernetes\${custom.aws_profile}$aws$azure$pulumi$nix_shell$cmd_duration$shlvl";

            add_newline = false;
            command_timeout = 1000;

            fill = {
              symbol = " ";
              disabled = false;
            };

            username.format = "[$user]($style)";
            hostname = {
              format = "[@$hostname]($style) ";
              ssh_only = true;
              style = "bold green";
            };

            shlvl = {
              format = "[$symbol $shlvl]($style)";
              style = "bold yellow";
              threshold = 2;
              disabled = false;
            };

            cmd_duration.format = "[$duration]($style) ";

            directory = {
              style = "bold green";
              format = "[$path ]($style)[$read_only]($read_only_style)";
              truncation_length = 3;
            };

            # Name of the linked git worktree; silent in the main worktree.
            # A linked worktree's git-dir is <repo>/.git/worktrees/<name>, so the
            # basename is the worktree name whenever git-dir != git-common-dir.
            custom.git_worktree = {
              description = "Current git worktree name (linked worktrees only)";
              require_repo = true;
              when = ''[ "$(git rev-parse --path-format=absolute --git-dir)" != "$(git rev-parse --path-format=absolute --git-common-dir)" ]'';
              command = ''basename "$(git rev-parse --git-dir)"'';
              format = "[$symbol$output]($style) ";
              symbol = "󰙅 ";
              style = "bold purple";
            };

            nix_shell = {
              format = " [($name<-)$symbol]($style) ";
              impure_msg = "";
              symbol = " ";
              style = "bold red";
            };

            kubernetes = {
              symbol = "⎈ ";
              format = " [$symbol$context(\\($namespace\\))]($style) ";
              style = "bright-blue";
              disabled = false;
              contexts = [
                {
                  context_pattern = ".*2729:cluster/cloud";
                  style = "bright-red";
                  symbol = "🚨";
                }
                {
                  context_pattern = ".*6246:cluster/cloud";
                  style = "bright-red";
                  symbol = "🚨";
                }
                {
                  context_pattern = ".*1712:cluster/cloud";
                  style = "bright-red";
                  symbol = "🚨";
                }
                {
                  context_pattern = ".*8219:cluster/cloud";
                  style = "bright-red";
                  symbol = "🚨";
                }
                {
                  context_pattern = ".*7106:cluster/cloud";
                  style = "bright-red";
                  symbol = "🚨";
                }
                {
                  context_pattern = ".*5089:cluster/cloud-controlplane";
                  style = "bright-red";
                  symbol = "🚨";
                }
                # AKS prod clusters — same warning as the prod contexts above
                {
                  context_pattern = "aks-.*-prod-.*";
                  style = "bright-red";
                  symbol = "🚨";
                }
              ];
            };

            # AWS profile, shortened by pattern so no account names live in this repo.
            # "<svc>-<env>-<region>-<role>" -> "<svc>-<env>"; multi-word prefixes become
            # initials ("cloud-controlplane-prod-use1-admin" -> "cc-prod"). Region is
            # rendered separately by the aws module above.
            custom.aws_profile = {
              description = "Shortened AWS profile name";
              when = ''[ -n "$AWS_PROFILE" ]'';
              command = ''printf '%s' "$AWS_PROFILE" | awk -F- '{ env=""; n=0; for (i=1; i<=NF; i++) if ($i ~ /^(prod|production|staging|stage|stg|dev|test|qa|sandbox)$/) { env=$i; n=i-1; break } if (env == "") { print; exit } if (n == 0) { print env; exit } if (n == 1) { pre=$1 } else { pre=""; for (j=1; j<=n; j++) pre = pre substr($j,1,1) } print pre "-" env }' '';
              format = " [$symbol$output]($style)";
              symbol = " ";
              style = "bold yellow";
            };

            # Azure subscription (name comes from ~/.azure/azureProfile.json)
            azure = {
              format = " [$symbol$subscription]($style) ";
              symbol = "󰠅 ";
              style = "bold sapphire";
              disabled = false;
            };

            pulumi = {
              format = " [$symbol$stack]($style) ";
              style = "bold blue";
              disabled = false;
            };

            character = {
              error_symbol = "[✖](bold fg:red)";
              success_symbol = "[>](bold green)";
              vimcmd_symbol = "[<<-](bold yellow)";
              vimcmd_visual_symbol = "[<<-](bold cyan)";
              vimcmd_replace_symbol = "[<<-](bold purple)";
              vimcmd_replace_one_symbol = "[<<-](bold purple)";
            };

            time = {
              format = "\\[[$time]($style)\\]";
              disabled = false;
            };

            gcloud.format = "on [$symbol$active(/$project)(\\($region\\))]($style)";
            # Profile name comes from custom.aws_profile below; this renders only the region.
            aws = {
              format = "[(\\($region\\))]($style) ";
              symbol = " ";
              region_aliases = {
                us-east-1 = "use1";
                us-west-2 = "usw2";
                us-east-2 = "use2";
                eu-west-1 = "euw1";
                ap-south-1 = "aps1";
              };
            };

            # Icons
            conda.symbol = " ";
            dart.symbol = " ";
            directory.read_only = " ";
            docker_context.symbol = " ";
            elm.symbol = " ";
            elixir.symbol = "";
            gcloud.symbol = " ";
            git_branch.symbol = " ";
            golang.symbol = " ";
            hg_branch.symbol = " ";
            java.symbol = " ";
            julia.symbol = " ";
            memory_usage.symbol = "󰍛 ";
            nim.symbol = "󰆥 ";
            nodejs.symbol = " ";
            package.symbol = "󰏗 ";
            pulumi.symbol = "󰏗 ";
            perl.symbol = " ";
            php.symbol = " ";
            python.symbol = " ";
            ruby.symbol = " ";
            rust.symbol = " ";
            scala.symbol = " ";
            shlvl.symbol = "";
            swift.symbol = "󰛥 ";
            terraform.symbol = "󱁢";

            palette = "catppuccin_mocha";
            palettes.catppuccin_mocha = {
              rosewater = "#f5e0dc";
              flamingo = "#f2cdcd";
              pink = "#f5c2e7";
              mauve = "#cba6f7";
              red = "#f38ba8";
              maroon = "#eba0ac";
              peach = "#fab387";
              yellow = "#f9e2af";
              green = "#a6e3a1";
              teal = "#94e2d5";
              sky = "#89dceb";
              sapphire = "#74c7ec";
              blue = "#89b4fa";
              lavender = "#b4befe";
              text = "#cdd6f4";
              subtext1 = "#bac2de";
              subtext0 = "#a6adc8";
              overlay2 = "#9399b2";
              overlay1 = "#7f849c";
              overlay0 = "#6c7086";
              surface2 = "#585b70";
              surface1 = "#45475a";
              surface0 = "#313244";
              base = "#1e1e2e";
              mantle = "#181825";
              crust = "#11111b";
            };
          };
        };
      };
    };
}
