{ config, lib, pkgs, ... }: {
  imports = [
    ./1password
    ./alacritty
    ./boot
    ./bluetooth
    ./discord
    ./fileSystems
    ./git
    ./hyprland
    ./joshuto
    ./mako
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
