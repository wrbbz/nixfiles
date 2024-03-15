{ config, lib, pkgs, ... }: {
  imports = [
    ./1password
    ./alacritty
    ./aerc
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
    ./opengl
    ./pass
    ./podman
    ./qutebrowser
    ./slack
    ./starship
    ./steam
    ./unfree
    ./v4l2
    ./wofi
    ./zsh
  ];
}
