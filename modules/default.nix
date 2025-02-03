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
    ./qutebrowser
    ./starship
    ./telepresence
    ./unfree
    ./yamusic
    ./zsh
  ];
}
