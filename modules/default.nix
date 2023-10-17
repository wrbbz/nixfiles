{ config, lib, pkgs, ... }: {
  imports = [
    ./1password
    ./alacritty
    ./boot
    ./bluetooth
    ./cli
    ./discord
    ./fileSystems
    ./git
    ./hyprland
    ./joshuto
    ./networking
    ./nvim
    ./pass
    ./podman
    ./qutebrowser
    ./slack
    ./starship
    ./unfree
    ./v4l2
    ./wofi
    ./zsh
  ];
}
