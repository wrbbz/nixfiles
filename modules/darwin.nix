{ config, lib, pkgs, ... }: {
  imports = [
    ./brew
    ./git
    ./nvim
    ./zsh
  ];
}
