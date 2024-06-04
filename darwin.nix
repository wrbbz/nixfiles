{ pkgs, ... }: {

  services.nix-daemon.enable = true;

  nix = {
    gc = {
      user = "root";
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 14d";
    };
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  users.users.wrbbz = {
    isHidden = false;
    home = "/Users/wrbbz";
    shell = pkgs.zsh;
  };

  security.pam.enableSudoTouchIdAuth = true;

  home-manager.users.wrbbz = {
    home = {
      username = "wrbbz";
      stateVersion = "23.05";
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
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

}
