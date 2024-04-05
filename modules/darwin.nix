{ config, lib, pkgs, ... }: {
services.nix-daemon.enable = true;
imports = [
    ./git
  ];
}
