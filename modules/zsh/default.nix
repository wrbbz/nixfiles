{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
nxuildCommand = if pkgs.stdenv.isLinux
          then
            "doas nixos-rebuild build --flake /etc/nixos"
          else
            "nix run nix-darwin -- build --flake ~/repos/nixfiles";
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
        autosuggestion.enable = true;
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
          nxwitch = if pkgs.stdenv.isLinux
            then
              "doas nixos-rebuild switch --flake /etc/nixos"
            else
              "nix run nix-darwin -- switch --flake ~/repos/nixfiles";
          nxuild = (if pkgs.stdenv.isLinux
            then
              "doas nixos-rebuild build --flake /etc/nixos"
            else
              "nix run nix-darwin -- build --flake ~/repos/nixfiles")
            + " && nvd diff /run/current-system result";
          sdfailed="systemctl list-units --failed";
          ssproxy="ssh -D 8118 -C -q -N";
          suspendless="systemd-inhibit --what=handle-lid-switch sleep infinity";
        };
        localVariables = {
          WORDCHARS = "*?_[]~=&;!#$%^(){}<>";
        };
        initContent = ''
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
            exec start-hyprland
          fi
          if [[ ! $DISPLAY && $XDG_VTNR -eq 2 ]]; then
            exec gamescope -e -- steam
          fi
          if [[ $(uname -m) == 'arm64' ]]; then
               eval "$(/opt/homebrew/bin/brew shellenv)"
          fi
        '';
      };
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
        options = [ "--cmd cd" ];
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
