{ config, lib, pkgs, ... }: {
  imports = [
    ./alacritty
    ./boot
    ./fileSystems
    ./networking
    ./starship
    ./zsh
  ];
}
