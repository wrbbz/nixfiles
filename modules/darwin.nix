{ config, lib, pkgs, ... }: {
  imports = [
    ./alacritty
    ./brew
    ./dev
    ./git
    ./kubernetes
    ./nvim
    ./pass
    ./starship
    ./zsh
  ];
}
