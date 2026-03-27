{ config, lib, pkgs, ... }: {
  imports = [
    ./sops
    ./aerc
    ./alacritty
    ./claude
    ./cli
    ./dev
    ./firefox
    ./git
    ./joshuto
    ./kubernetes
    ./nvim
    ./pass
    ./qutebrowser
    ./slack
    ./starship
    ./telegram
    ./telepresence
    ./unfree
    ./yamusic
    ./zsh
  ];
}
