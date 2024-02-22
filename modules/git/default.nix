{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    git.enable = mkOption {
      description = "Enable my customized git";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.git.enable {
    home-manager.users.wrbbz = {
      programs.git = {
        enable = true;
        userEmail = "me@wrbbz.com";
        userName = "Arseniy Zorin";
        aliases = {
          lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n%C(white)%s%C(reset) %C(dim green)- %an%C(reset)' --all";
        };
        extraConfig = {
          init = {
            defaultBranch = "main";
          };
          pull = {
            rebase = true;
          };
        };
        ignores = [
          "*.swp"
          ".envrc"
        ];
        includes = [{
          contents = {
            commit = {
              template = "~/.config/git/message";
            };
          };
        }
        {
          condition = "gitdir:~/work/";
          contents = {
            user = {
              email = "a.zorin@cs.money";
            };
          };
        }];
      };
      home.file = {
        ".config/git/message" = { source = ./message; };
      };
    };
  };
}
