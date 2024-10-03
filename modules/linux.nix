{ config, lib, pkgs, ... }: {
  imports = [
    ./1password
    ./bluetooth
    ./boot
    ./fileSystems
    ./hyprland
    ./keymapp
    ./networking
    ./obs
    ./opengl
    ./podman
    ./qutebrowser
    ./slack
    ./steam
    ./tailscale
    ./unfree
    ./wofi
  ];
}
