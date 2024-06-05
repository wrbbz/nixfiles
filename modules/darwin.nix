{ config, lib, pkgs, ... }: {
  imports = [
    ./alacritty
    ./brew
    ./git
    ./kubernetes
    ./nvim
    ./pass
    ./starship
    ./zsh
  ];
}
