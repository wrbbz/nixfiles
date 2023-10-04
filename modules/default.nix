{ config, lib, pkgs, ... }: {
  imports = [
    ./alacritty
    ./boot
    ./fileSystems
    ./git
    ./hyprland
    ./networking
    ./pass
    ./starship
    ./zsh
  ];
}
