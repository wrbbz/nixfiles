{ config, lib, pkgs, ... }: {
  imports = [
    ./alacritty
    ./brew
    ./cli
    ./dev
    ./git
    ./kubernetes
    ./nvim
    ./pass
    ./starship
    ./zsh
  ];
}
