# configuration in this file only applies to exampleHost host
#
# only my-config.* and zfs-root.* options can be defined in this file.
#
# all others goes to `configuration.nix` under the same directory as
# this file. 

{ system, pkgs, ... }: {
  inherit pkgs system;
  zfs-root = {
    boot = {
      devNodes = "/dev/disk/by-id/";
      bootDevices = [  "ata-Samsung_SSD_850_PRO_1TB_S3D2NX0J910298W" ];
      immutable = false;
      availableKernelModules = [ "ahci" "ohci_pci" "ehci_pci" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
      removableEfi = true;
      kernelParams = [ ];
      sshUnlock = {
        # read sshUnlock.txt file.
        enable = false;
        authorizedKeys = [ ];
      };
    };
    networking = {
      # read changeHostName.txt file.
      hostName = "wrbbzCool";
      timeZone = "Europe/Moscow";
      hostId = "400fb1e7";
    };
  };

  my-config = {
    alacritty.enable = true;
    bluetooth.enable = true;
    cli.enable = true;
    discord.enable = true;
    git.enable = true;
    hypr = {
      enable = true;
      monitors = [
        ",preferred,auto,auto"
      ];
      # workspaces = [
      #   "1, monitor:HDMI-A-1, default:true"
      #   "2, monitor:HDMI-A-1"
      #   "3, monitor:HDMI-A-1"
      #   "4, monitor:HDMI-A-1"
      #   "5, monitor:HDMI-A-1"
      #   "6, monitor:HDMI-A-1"
      #   "7, monitor:HDMI-A-1"
      #   "8, monitor:HDMI-A-1"
      #   "9, monitor:HDMI-A-1"
      # ];
      # paperConfig = ''
      #   ipc = off
      #   splash = off
      #   preload = /home/wrbbz/.pictures/bg.jpg
      #   wallpaper = HDMI-A-1,contain:/home/wrbbz/.pictures/bg.jpg
      # '';
    };
    joshuto.enable = true;
    nvim.enable = true;
    one-password.enable = true;
    pass.enable = true;
    podman.enable = true;
    qutebrowser.enable = true;
    slack.enable = true;
    starship.enable = true;
    v4l2.enable = true;
    wofi.enable = true;
    zsh.enable = true;
  };

  security.polkit.enable = true;
}
