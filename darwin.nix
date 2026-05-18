{ pkgs, ... }:
let
  # macOS sets com.apple.macl (Mandatory Access Control) on .app bundles when any
  # sandboxed app opens them. This xattr cannot be removed even by root, and causes
  # nix's internal chmod call during GC to fail with EPERM — even though rm works fine.
  # Fix: retry GC, parse the offending path from the error, rm -rf it, repeat.
  nixGcScript = ''
    GC=/run/current-system/sw/bin/nix-collect-garbage
    output=""
    for _i in $(seq 1 20); do
      output=$("$GC" --delete-older-than 14d 2>&1)
      if [ $? -eq 0 ]; then
        printf '%s\n' "$output"
        exit 0
      fi
      path=$(printf '%s' "$output" | grep -oE 'chmod "[^"]*"' | head -1 | sed 's/chmod "//;s/"//')
      if [ -z "$path" ]; then
        printf '%s\n' "$output" >&2
        exit 1
      fi
      store=$(printf '%s' "$path" | grep -oE '^/nix/store/[^/]+')
      printf 'Removing %s (macOS MAC chmod restriction)\n' "$store" >&2
      rm -rf "$store"
    done
    printf '%s\n' "$output" >&2
    exit 1
  '';
in
{
  environment.systemPackages = [
    # Run as: sudo nix-gc-clean
    (pkgs.writeShellScriptBin "nix-gc-clean" nixGcScript)
  ];

  launchd.daemons.nix-gc = {
    script = nixGcScript;
    serviceConfig = {
      StartCalendarInterval = [{ Weekday = 0; Hour = 2; Minute = 0; }];
      StandardOutPath = "/var/log/nix-gc.log";
      StandardErrorPath = "/var/log/nix-gc.log";
    };
  };

  nix = {
    gc = {
      automatic = false;
      options = "--delete-older-than 14d";
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      sandbox = "relaxed";
    };
  };

  users.users.wrbbz = {
    isHidden = false;
    home = "/Users/wrbbz";
    shell = pkgs.zsh;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  home-manager.users.wrbbz = {
    home = {
      username = "wrbbz";
      stateVersion = "26.05";
    };
  };

  system = {
    primaryUser = "wrbbz";
    defaults = {
      dock = {
        autohide = true;
        orientation = "right";
        persistent-apps = [
          "/Applications/Safari.app"
          "/System/Applications/Calendar.app"
          "/System/Applications/Mail.app"
        ];
        show-recents = false;
      };
      NSGlobalDomain = {
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
    };

    # # Reload all settings without relog/reboot
    # activationScripts.postUserActivation.text = ''
    #   /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    # '';

    # kyboard = {
    #   enableKeyMapping = true;
    #   nonUS.remapTilde = true;
    #   /* Swaps caps and esc */
    #   userKeyMapping = [
    #     {
    #       HIDKeyboardModifierMappingSrc = 30064771129;
    #       HIDKeyboardModifierMappingDst = 30064771113;
    #     }
    #     {
    #       HIDKeyboardModifierMappingSrc = 30064771113;
    #       HIDKeyboardModifierMappingDst = 30064771129;
    #     }
    #   ];
    # };
  };
}
