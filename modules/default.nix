{ config, lib, pkgs, ... }: {
  imports = [
    ./sops
    ./aerc
    ./alacritty
    ./claude
    ./cli
    ./dev
    ./do-next
    ./firefox
    ./git
    ./joshuto
    ./kubernetes
    ./nvim
    ./pass
    ./qutebrowser
    ./sidra
    ./slack
    ./slk
    ./starship
    ./telegram
    ./unfree
    ./yamusic
    ./zsh
  ];
}
