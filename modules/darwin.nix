{ config, lib, pkgs, ... }: {
  imports = [
    ./brew
    ./kanata
    ./mkalias
  ];
}
