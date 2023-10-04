{ config, lib, pkgs, ... }: {
  imports = [
    ./alacritty
    ./boot
    ./fileSystems
    ./hyprland
    ./networking
    ./pass
    ./starship
    ./zsh
  ];
}
