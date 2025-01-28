{ config, lib, pkgs, ... }: {
  imports = [
    ./1password
    ./bluetooth
    ./boot
    ./fileSystems
    ./hyprland
    ./jellyfin
    ./keymapp
    ./networking
    ./obs
    ./opengl
    ./podman
    ./qutebrowser
    ./slack
    ./steam
    ./tailscale
    ./transmission
    ./wofi
  ];
}
