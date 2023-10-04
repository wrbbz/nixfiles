{ config, lib, pkgs, ... }: {
  imports = [
    ./alacritty
    ./boot
    ./fileSystems
    ./git
    ./hyprland
    ./networking
    ./pass
    ./slack
    ./starship
    ./unfree
    ./zsh
  ];
}
