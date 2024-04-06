{ config, lib, pkgs, ... }: {
  services.nix-daemon.enable = true;
  imports = [
      ./git
    ];
  users.users.wrbbz = {
    initialHashedPassword = "!";
    isNormalUser = true;
    home = "/Users/wrbbz";
    shell = pkgs.zsh;
  };
}
