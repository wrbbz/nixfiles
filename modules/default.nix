{ config, lib, pkgs, ... }: {
  imports = [
    ./aerc
    ./alacritty
    ./cli
    ./dev
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
