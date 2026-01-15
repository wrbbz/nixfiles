{ config, lib, pkgs, ... }: {
  imports = [
    ./1password
    ./acme
    ./bluetooth
    ./boot
    ./cloudflare
    ./fileSystems
    ./flatpak
    ./hyprland
    ./jellyfin
    ./keymapp
    ./miniflux
    ./networking
    ./obs
    ./opengl
    ./podman
    ./rbw
    ./steam
    ./tailscale
    ./transmission
    ./v4l2
    ./wofi
  ];
}
