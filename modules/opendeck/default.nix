{ config, lib, pkgs, ... }:

let inherit (lib) types mkIf mkOption;
in {
  options.my-config = {
    opendeck.enable = mkOption {
      description = "Install OpenDeck (Stream Deck alternative) via Flatpak";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.opendeck.enable {
    assertions = [
      {
        assertion = config.my-config.flatpak.enable;
        message = "my-config.opendeck.enable requires my-config.flatpak.enable = true";
      }
    ];

    systemd.services.flatpak-install-opendeck = {
      description = "Install OpenDeck Flatpak";
      wantedBy = [ "multi-user.target" ];
      after = [ "flatpak-repo.service" "network-online.target" ];
      wants = [ "network-online.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak install --assumeyes flathub me.amankhanna.opendeck
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };
}
