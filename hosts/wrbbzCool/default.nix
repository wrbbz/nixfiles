# only my-config.* and zfs-root.* options can be defined in this file.
#
# all others goes to `configuration.nix` under the same directory as
# this file.

{ system, pkgs, ... }: {
  inherit pkgs system;
  fileSystems."/home/wrbbz/.local/share/Steam" = {
    device = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_1TB_S6PTNM0T520867R-part1";
    fsType = "ext4";
    options = [ "noatime" ];
  };
  zfs-root = {
    boot = {
      devNodes = "/dev/disk/by-id/";
      bootDevices = [  "ata-Samsung_SSD_850_PRO_1TB_S3D2NX0J910298W" ];
      immutable = false;
      availableKernelModules = [ "ahci" "ohci_pci" "ehci_pci" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
      removableEfi = true;
      kernelParams = [ ];
      sshUnlock = {
        enable = false;
        authorizedKeys = [ ];
      };
    };
    networking = {
      hostName = "wrbbzCool";
      timeZone = "Europe/Moscow";
      hostId = "400fb1e7";
    };
  };

  my-config = {
    aerc.enable = true;
    alacritty.enable = true;
    bluetooth.enable = true;
    cli.enable = true;
    cloudflare.enable = true;
    dev.enable = true;
    firefox.enable = true;
    git = {
      enable = true;
      signing = {
        enable = true;
        personal = "0xB43D995D25011DFA";
        work = "0x38AB470860769724";
      };
    };
    hypr = {
      enable = true;
      monitors = [
        ",preferred,auto,auto"
      ];
      workspaces = [
        "1, monitor:DP-1, default:true"
        "2, monitor:DP-1"
        "3, monitor:DP-1"
        "4, monitor:DP-1"
        "5, monitor:DP-1"
        "6, monitor:DP-1"
        "7, monitor:DP-1"
        "8, monitor:DP-1"
        "9, monitor:DP-1"
      ];
      paperConfig = ''
        ipc = off
        splash = off
        preload = /home/wrbbz/.pictures/bg.png
        wallpaper = DP-1,/home/wrbbz/.pictures/bg.png
      '';
    };
    joshuto.enable = true;
    keymapp.enable = true;
    kubernetes.enable = true;
    nvim.enable = true;
    obs.enable = true;
    one-password.enable = true;
    opengl.enable = true;
    pass.enable = true;
    podman.enable = true;
    qutebrowser.enable = true;
    rbw.enable = true;
    slack.enable = true;
    starship.enable = true;
    steam.enable = true;
    tailscale.enable = true;
    telepresence.enable = true;
    v4l2.enable = true;
    wofi.enable = true;
    yamusic.enable = false;
    zsh.enable = true;
  };
}
