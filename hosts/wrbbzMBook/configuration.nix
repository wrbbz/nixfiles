{ pkgs, ... }: {

  home-manager.users.wrbbz = {
    home.username = "wrbbz";
    home.stateVersion = "23.05";
  };
  environment.systemPackages = with pkgs; [
    glow
    jq
    k9s
  ];
}
