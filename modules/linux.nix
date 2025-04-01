{ config, lib, pkgs, ... }: {
  imports = [
    ./1password
    ./bluetooth
    ./boot
    ./cloudflare
    ./fileSystems
    ./firefox
    ./hyprland
    ./jellyfin
    ./keymapp
    ./miniflux
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
