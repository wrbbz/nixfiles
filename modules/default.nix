{ config, lib, pkgs, ... }: {
  imports = [
    ./alacritty
    ./boot
    ./fileSystems
    ./git
    ./hyprland
    ./networking
    ./nvim
    ./pass
    ./slack
    ./starship
    ./unfree
    ./zsh
  ];
}
