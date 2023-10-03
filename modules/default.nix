{ config, lib, pkgs, ... }: {
  imports = [
    ./alacritty
    ./boot
    ./fileSystems
    ./hyprland
    ./networking
    ./starship
    ./zsh
  ];
}
