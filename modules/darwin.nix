{ config, lib, pkgs, ... }: {
  imports = [
    ./alacritty
    ./git
    ./zsh
  ];
}
