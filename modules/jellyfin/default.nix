{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    jellyfin.enable = mkOption {
      description = "Enable jellyfin with nginx";
      type = types.bool;
      default = false;
    };
    jellyfin.domain = mkOption {
      description = "Domain for jellyfin";
      type = types.str;
      default = "jellyfin.wrb.bz";
    };
  };

  config = mkIf config.my-config.jellyfin.enable {
    home-manager.users.wrbbz = {
      home.packages = with pkgs; [
        jellyfin
      ];
    };
    services = {
      nginx = {
        virtualHosts."${config.my-config.jellyfin.domain}" = {
          forceSSL = true;
          sslCertificate = "/etc/letsencrypt/live/jellyfin.wrb.bz/fullchain.pem";
          sslCertificateKey = "/etc/letsencrypt/live/jellyfin.wrb.bz/privkey.pem";
          locations."/" = {
            proxyPass = "http://localhost:8096";
          };
        };
      };
      jellyfin = {
        enable = true;
        openFirewall = true;
      };
    };
  };
}
