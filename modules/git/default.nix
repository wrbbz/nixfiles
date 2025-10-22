{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkMerge mkOption;
in {
  options.my-config = {
    git = {
      enable = mkOption {
        description = "Enable my customized git";
        type = types.bool;
        default = false;
      };
      signing = {
        enable = mkOption {
          description = "Enables signing commits and tags";
          type = types.bool;
          default = false;
        };
      };
      profiles = {
        work = {
          enable = mkOption {
            description = "Enables work profile";
            type = types.bool;
            default = false;
          };
          signingKey = mkOption {
            description = "Work signing key";
            type = types.str;
          };
        };
        spbpu = {
          enable = mkOption {
            description = "Enables spbpu profile";
            type = types.bool;
            default = false;
          };
          signingKey = mkOption {
            description = "SPbPU signing key";
            type = types.str;
          };
        };
        personal = {
          signingKey = mkOption {
            description = "Personal signing key";
            type = types.str;
          };
        };
      };
    };
  };

  config = mkIf config.my-config.git.enable {
    home-manager.users.wrbbz = {
      home.packages = with pkgs; [
        gh
        git-cliff
        glab
      ];
      programs = {
        git = {
          enable = true;
          signing = mkIf config.my-config.git.signing.enable {
            key = config.my-config.git.profiles.personal.signingKey;
            signByDefault = true;
          };
          settings = {
            user = {
              email = "me@wrb.bz";
              name = "Arsenii Zorin";
            };
            alias = {
              lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n%C(white)%s%C(reset) %C(dim green)- %an%C(reset)' --all";
            };
            extraConfig = {
              init = {
                defaultBranch = "main";
              };
              safe.directory = "/etc/nixos";
              pull = {
                rebase = true;
              };
              commit = {
                template = "~/.config/git/message";
              };
              core.hooksPath = "~/.config/git/hooks";
            };
          };
          ignores = [
            "*.swp"
            ".envrc"
            ".npmrc"
            ".werf*"
            ".netrc"
          ];
          includes = [
            (mkIf config.my-config.git.profiles.work.enable {
              condition = "gitdir:~/work/excorp/";
              contents = {
                user = mkMerge [
                  {
                    email = "a.zorin@cs.money";
                  }
                  (mkIf config.my-config.git.signing.enable {
                    signingkey = config.my-config.git.profiles.work.signingKey;
                  })
                ];
              };
            })
            (mkIf config.my-config.git.profiles.spbpu.enable {
              condition = "gitdir:~/work/spbpu/";
              contents = {
                user = mkMerge [
                  {
                    email = "arseny.zorin@spbpu.com";
                  }
                  (mkIf config.my-config.git.signing.enable {
                    signingkey = config.my-config.git.profiles.spbpu.signingKey;
                  })
                ];
              };
            })
          ];
        };
        delta = {
          enable = true;
          enableGitIntegration = true;
        };
      };
      home.file = {
        ".config/git/message" = { source = ./message; };
        ".config/git/hooks/commit-msg" = {
          executable = true;
          source = ./hooks/commit-msg;
        };
      };
    };
  };
}
