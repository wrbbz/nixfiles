{ config, lib, pkgs, ... }: {
  imports = [
    ./alacritty
    ./boot
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
