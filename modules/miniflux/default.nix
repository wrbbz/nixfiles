{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    miniflux.enable = mkOption {
      description = "Enable miniflux with nginx";
      type = types.bool;
      default = false;
    };
    miniflux.domain = mkOption {
      description = "Domain for miniflux";
      type = types.str;
      default = "wrb.bz";
    };
    miniflux.port = mkOption {
      description = "Port for miniflux";
      type = types.port;
      default = 8097;
    };
  };

  config = mkIf config.my-config.miniflux.enable {
    home-manager.users.wrbbz = {
      home.packages = with pkgs; [
        miniflux
      ];
    };
    services = {
      miniflux = {
        enable = true;
        adminCredentialsFile = "/opt/miniflux/admin";
        config = {
          LISTEN_ADDR = "127.0.0.1:${toString config.my-config.miniflux.port}";
          BASE_URL = "https://rss.${config.my-config.miniflux.domain}";
        };
      };
      nginx = {
        virtualHosts."rss.${config.my-config.miniflux.domain}" = {
          forceSSL = true;
          sslCertificate = "/var/lib/acme/${config.my-config.miniflux.domain}/cert.pem";
          sslCertificateKey = "/var/lib/acme/${config.my-config.miniflux.domain}/key.pem";
          locations."/" = {
            proxyPass = "http://localhost:${toString config.my-config.miniflux.port}";
          };
        };
      };
    };
  };
}
