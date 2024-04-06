{ pkgs, ... }: {

  home-manager.users.wrbbz = {
    home = {
      username = "wrbbz";
      stateVersion = "23.05";
    };
  };
  environment.systemPackages = with pkgs; [
    "pulumi-bin"
  ];
}
