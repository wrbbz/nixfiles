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
      home.packages = with pkgs; [
        git-cliff
        glab
      ];
      programs.git = {
        enable = true;
        userEmail = "me@wrb.bz";
        userName = "Arsenii Zorin";
        signing = {
          key = "0xB43D995D25011DFA";
          signByDefault = true;
        };
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
          ".npmrc"
          ".werf*"
          ".netrc"
        ];
        includes = [{
          condition = "gitdir:~/work/";
          contents = {
            user = {
              email = "a.zorin@cs.money";
              signingkey = "0x38AB470860769724";
            };
            commit = {
              template = "~/.config/git/message";
            };
            core.hooksPath = "~/.config/git/hooks";
          };
        }];
        delta = {
          enable = true;
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
