{ config, lib, pkgs, ... }: {
  imports = [
    ./alacritty
    ./boot
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
