{ pkgs, ... }: {

  nix = {
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 14d";
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      sandbox = true;
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
      stateVersion = "23.05";
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
          "/Applications/Firefox.app"
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

    keyboard = {
      enableKeyMapping = true;
      nonUS.remapTilde = true;
      /* Swaps caps and esc */
      userKeyMapping = [
        {
          HIDKeyboardModifierMappingSrc = 30064771129;
          HIDKeyboardModifierMappingDst = 30064771113;
        }
        {
          HIDKeyboardModifierMappingSrc = 30064771113;
          HIDKeyboardModifierMappingDst = 30064771129;
        }
      ];
    };
  };
}
