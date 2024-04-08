{ config, lib, pkgs, ... }: {
  imports = [
    ./alacritty
    ./brew
    ./git
    ./nvim
    ./pass
    ./zsh
  ];
}
