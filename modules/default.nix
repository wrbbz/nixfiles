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
    ./telegram
    ./telepresence
    ./unfree
    ./yamusic
    ./zsh
  ];
}
