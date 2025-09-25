# only my-config.* and zfs-root.* options can be defined in this file.
#
# all others goes to `configuration.nix` under the same directory as
# this file.

{ system, pkgs, ... }: {
  inherit pkgs system;
  zfs-root = {
    boot = {
      devNodes = "/dev/disk/by-id/";
      bootDevices = [ "nvme-GenMachine-NVMe1TB_2409VC2S038E0390" ];
      bootloader = "systemd";
      immutable = false;
      availableKernelModules = [ "nvme" "ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod" ];
      partitions = 3;
      partitionScheme = {
        efiBoot = "-part1";
        swap = "-part3";
        rootPool = "-part2";
      };
      removableEfi = true;
      kernelParams = [ ];
      sshUnlock = {
        enable = false;
        authorizedKeys = [ ];
      };
    };
    networking = {
      hostName = "wrbbzGM";
      timeZone = "Europe/Moscow";
      hostId = "3b9a1f97";
    };
  };

  my-config = {
    acme.enable = true;
    alacritty.enable = true;
    bluetooth.enable = true;
    cli.enable = true;
    dev.enable = true;
    git = {
      enable = true;
      signing = {
        enable = true;
      };
      profiles = {
        personal = {
          signingKey = "0xFC7707860149E41E";
        };
        # work = "0xEE08CED442647AB9";
      };
    };
    jellyfin.enable = true;
    joshuto.enable = true;
    miniflux.enable = true;
    nvim.enable = true;
    pass.enable = true;
    podman.enable = true;
    starship.enable = true;
    tailscale.enable = true;
    transmission.enable = true;
    zsh.enable = true;
  };
}
