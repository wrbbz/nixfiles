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
    jellyfin.port = mkOption {
      description = "Port for jellyfin";
      type = types.port;
      default = 8096;
    };
  };

  config = mkIf config.my-config.jellyfin.enable {
    home-manager.users.wrbbz = {
      home.packages = with pkgs; [
        jellyfin
      ];
    };
    services = {
      jellyfin = {
        enable = true;
        openFirewall = true;
      };
      nginx = {
        virtualHosts."${config.my-config.jellyfin.domain}" = {
          forceSSL = true;
          sslCertificate = "/etc/letsencrypt/live/${config.my-config.jellyfin.domain}/fullchain.pem";
          sslCertificateKey = "/etc/letsencrypt/live/${config.my-config.jellyfin.domain}/privkey.pem";
          locations."/" = {
            proxyPass = "http://localhost:${toString config.my-config.jellyfin.port}";
          };
        };
      };
    };
  };
}
