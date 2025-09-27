{ config, lib, pkgs, ... }: {
  imports = [
    ./aerc
    ./alacritty
    ./cli
    ./dev
    ./firefox
    ./git
    ./joshuto
    ./kubernetes
    ./nvim
    ./pass
    ./slack
    ./starship
    ./telepresence
    ./unfree
    ./yamusic
    ./zsh
  ];
}
