{ config, lib, pkgs, ... }: {
  imports = [
    ./alacritty
    ./git
    ./pass
    ./zsh
  ];
}
