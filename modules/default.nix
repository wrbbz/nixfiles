{ config, lib, pkgs, ... }: {
  imports = [
    ./alacritty
    ./boot
    ./bluetooth
    ./discord
    ./fileSystems
    ./git
    ./hyprland
    ./joshuto
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
