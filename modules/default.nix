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
    ./qutebrowser
    ./slack
    ./starship
    ./unfree
    ./zsh
  ];
}
