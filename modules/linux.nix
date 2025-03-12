{ config, lib, pkgs, ... }: {
  imports = [
    ./1password
    ./bluetooth
    ./boot
    ./cloudflare
    ./fileSystems
    ./hyprland
    ./jellyfin
    ./keymapp
    ./networking
    ./obs
    ./opengl
    ./podman
    ./qutebrowser
    ./rbw
    ./slack
    ./steam
    ./tailscale
    ./transmission
    ./wofi
  ];
}
