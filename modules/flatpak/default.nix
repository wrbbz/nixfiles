{ config, lib, pkgs, ... }:

let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    flatpak.enable = mkOption {
      description = "Enable flatpak usage";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.flatpak.enable {
    home-manager.users.wrbbz = {
      home.packages = with pkgs; [
        flatpak
      ];
    };
    services.flatpak.enable = true;
    systemd.services.flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}
