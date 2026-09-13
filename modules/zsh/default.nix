{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
nxuildCommand = if pkgs.stdenv.hostPlatform.isLinux
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
          alitle="printf '\\e]2;%s\\a'"; # Sets alacritty title for an already created window
          jqp="jq -C | less -R";
          ls="eza -Slhg --icons=always";
          la="eza -Slhga --icons=always";
          maps="telnet mapscii.me";
          nxwitch = if pkgs.stdenv.hostPlatform.isLinux
            then
              "doas nixos-rebuild switch --flake /etc/nixos"
            else
              "nix run nix-darwin -- switch --flake ~/repos/nixfiles";
          nxuild = (if pkgs.stdenv.hostPlatform.isLinux
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
        '' + lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
          # Boot the linux-builder VM, run the given command, then shut the
          # VM back down. Returns the command's exit code.
          with-linux-builder() {
            echo "Starting linux-builder VM..." >&2
            sudo launchctl bootstrap system /Library/LaunchDaemons/org.nixos.linux-builder.plist 2>/dev/null
            local i up=0
            for i in {1..60}; do
              if sudo nix store info --store 'ssh-ng://builder@linux-builder' &>/dev/null; then
                up=1
                break
              fi
              printf '\rWaiting for linux-builder VM... %ds' $((i * 2)) >&2
              sleep 2
            done
            echo >&2
            if [[ $up -ne 1 ]]; then
              echo "linux-builder VM did not come up after 120s, aborting" >&2
              sudo launchctl bootout system/org.nixos.linux-builder 2>/dev/null
              return 1
            fi
            echo "linux-builder VM is up" >&2
            "$@"
            local rc=$?
            # The VM's store is only a cache (builders-use-substitutes), so
            # drop everything but the system closure before shutting down.
            echo "Collecting garbage on linux-builder VM..." >&2
            sudo nix store gc --store 'ssh-ng://builder@linux-builder' 2>&1 | tail -n 1 >&2
            sudo launchctl bootout system/org.nixos.linux-builder
            return $rc
          }

          # Review a nixpkgs PR on all three platforms and post one combined
          # report to GitHub. Builders: aarch64-darwin locally, x86_64-linux on
          # wrbbzGM (must be reachable), aarch64-linux on the linux-builder VM
          # (started for the duration of the run).
          # Extra arguments are passed through to `nixpkgs-review pr`, e.g.:
          #   nixpkgs-review-all 547161 --package foo --extra-nixpkgs-config '{ cudaSupport = true; }'
          nixpkgs-review-all() {
            if [[ -z "$1" ]]; then
              echo "usage: nixpkgs-review-all <pr-number> [nixpkgs-review args...]" >&2
              return 1
            fi
            local pr="$1"
            shift
            GITHUB_TOKEN=$(gh auth token) with-linux-builder nixpkgs-review pr "$pr" --no-shell \
              --systems "aarch64-darwin x86_64-linux aarch64-linux" "$@"
          }

          # Build the current flake's checks and packages on all three
          # platforms — the flake-repo counterpart of nixpkgs-review-all.
          # Run from the flake's root; extra arguments pass to `nix build`.
          flake-build-all() {
            local sys name targets=()
            for sys in aarch64-darwin x86_64-linux aarch64-linux; do
              for name in $(nix eval ".#checks.$sys" --apply 'a: toString (builtins.attrNames a)' --raw 2>/dev/null); do
                targets+=(".#checks.$sys.$name")
              done
              for name in $(nix eval ".#packages.$sys" --apply 'a: toString (builtins.attrNames a)' --raw 2>/dev/null); do
                targets+=(".#packages.$sys.$name")
              done
            done
            if [[ ''${#targets[@]} -eq 0 ]]; then
              echo "no checks or packages found for the three platforms — is this a flake root?" >&2
              return 1
            fi
            printf 'building %d targets\n' ''${#targets[@]} >&2
            with-linux-builder nix build --keep-going --no-link --print-build-logs "''${targets[@]}" "$@"
          }
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
