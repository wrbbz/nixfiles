{ config, lib, pkgs, ... }: {
  imports = [
    ./aerc
    ./alacritty
    ./cli
    ./cloudflare
    ./dev
    ./git
    ./joshuto
    ./kubernetes
    ./nvim
    ./pass
    ./starship
    ./telepresence
    ./unfree
    ./yamusic
    ./zsh
  ];
}
