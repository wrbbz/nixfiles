# configuration in this file only applies to exampleHost host
#
# only zfs-root.* options can be defined in this file.
#
# all others goes to `configuration.nix` under the same directory as
# this file. 

{ system, pkgs, ... }: {
  inherit pkgs system;
  zfs-root = {
    boot = {
      devNodes = "/dev/disk/by-id/";
      bootDevices = [  "ata-Apacer_AS350_256GB_8B18070613B700011956" ];
      immutable = false;
      availableKernelModules = [  "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
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
      hostName = "wrbbzChief";
      timeZone = "Europe/Podgorica";
      hostId = "576459dd";
    };
  };

  my-config = {
    alacritty.enable = true;
    bluetooth.enable = true;
    cli.enable = true
    discord.enable = true;
    git.enable = true;
    hypr = {
      enable = true;
      monitors = ''
        monitor=,1920x1080@74,auto,auto
      '';
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
