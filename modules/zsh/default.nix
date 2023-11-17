{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    zsh.enable = mkOption {
      description = "Enable my customized zsh";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.zsh.enable {
    programs.zsh.enable = true;
    environment.systemPackages = with pkgs; [
      eza
      fx
    ];
    home-manager.users.wrbbz = {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;
        enableAutosuggestions = true;
        history = {
          share = true;
          ignoreDups = true;
          ignoreSpace = true;
        };
        defaultKeymap = "viins";
        shellAliases = {
          add-deleted="git status | grep 'deleted' | awk '{ print $2 }' | xargs git add";
          jqp="jq -C | less -R";
          ls="eza -Slhg --icons=always";
          la="eza -Slhga --icons=always";
          maps="telnet mapscii.me";
          nwitch="doas nixos-rebuild switch --flake /home/wrbbz/.nixfiles#wrbbzChief";
          nest="doas nixos-rebuild test --flake /home/wrbbz/.nixfiles#wrbbzChief";
          sdfailed="systemctl list-units --failed";
          ssproxy="ssh -D 1080 -C -q -N";
          suspendless="systemd-inhibit --what=handle-lid-switch sleep infinity";
        };
        localVariables = {
          WORDCHARS = "*?_[]~=&;!#$%^(){}<>";
        };
        initExtra = ''
          bindkey -e
          # Searches for lines with same beginning
          autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
          zle -N up-line-or-beginning-search
          zle -N down-line-or-beginning-search

          bindkey -- "^P" up-line-or-beginning-search
          bindkey -- "^N" down-line-or-beginning-search
        '';
        # TODO: exec Hyprland and gamescope only when they are enabled
        profileExtra = ''
          if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
            exec Hyprland
          fi
        '';
        #   if [[ ! $DISPLAY && $XDG_VTNR -eq 2 ]]; then
        #     exec gamescope -e -- steam
        #   fi
      };
      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}

# Some aliases have functions to implement them.
# I haven't figured out how to use them yet.
#
# Regular config chunks to migrate later:
#
###### Dictionary ######
#
#   alias trans='__trans'
#   alias def='__def'
#   __trans() {
#   	sdcv --color --data-dir /usr/share/stardict/dic/trans/ $* | less -R
#   }
#   __def() {
#   	sdcv --color --data-dir /usr/share/stardict/dic/def/ $* | less -R
#   }
#
###### oui lookup ######
#
#   alias oui='__oui'
#   __oui() {
#   	grep $* -i /usr/share/nmap/nmap-mac-prefixes
#   }
#
###### weather ######
# 
#   alias wttr="__wttr"
#   __wttr() {
#     curl "wttr.in/$*"
#   }
