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
      bootDevices = [  "ata-Hitachi_HDS721050CLA362_JP5521HA2XA64T" ];
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
      hostId = "d9a96eaa";
    };
  };

  my-config = {
    alacritty.enable = true;
    zsh.enable = true;
    starship.enable = true;
  };
}
