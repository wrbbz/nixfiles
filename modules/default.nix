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
    ./mako
    ./networking
    ./nvim
    ./pass
    ./podman
    ./qutebrowser
    ./slack
    ./starship
    ./unfree
    ./wofi
    ./zsh
  ];
}
