{ pkgs, ... }: {

  services.nix-daemon.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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

}
