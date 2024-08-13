{ config, lib, pkgs, ... }: {
  imports = [
    ./1password
    ./alacritty
    ./aerc
    ./boot
    ./bluetooth
    ./cli
    ./dev
    ./fileSystems
    ./git
    ./hyprland
    ./joshuto
    ./keymapp
    ./kubernetes
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
