{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    transmission.enable = mkOption {
      description = "Enable transmission with nginx";
      type = types.bool;
      default = false;
    };
    transmission.domain = mkOption {
      description = "Domain for transmission";
      type = types.str;
      default = "transmission.wrb.bz";
    };
    transmission.port = mkOption {
      description = "Port for transmission";
      type = types.port;
      default = 9091;
    };
  };

  config = mkIf config.my-config.transmission.enable {
    home-manager.users.wrbbz = {
      home.packages = with pkgs; [
        transmission_4-qt
      ];
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "me+acme@wrb.bz";
      certs."${config.my-config.transmission.domain}" = {
        dnsProvider = "cloudflare";
        environmentFile = "/opt/certs/cf/acme.credentials";
        group = config.services.nginx.group;
      };
    };
    services = {
      transmission = {
        enable = true;
        openRPCPort = true;
        settings = {
          download-dir = "/media/";
          rpc-bind-address = "0.0.0.0";
          rpc-whitelist = "127.0.0.1,192.168.8.*";
          rpc-port = config.my-config.transmission.port;
        };
      };
      nginx = {
        virtualHosts."${config.my-config.transmission.domain}" = {
          forceSSL = true;
          sslCertificate = "/var/lib/acme/${config.my-config.transmission.domain}/cert.pem";
          sslCertificateKey = "/var/lib/acme/${config.my-config.transmission.domain}/key.pem";
          locations."/" = {
            proxyPass = "http://localhost:${toString config.my-config.transmission.port}";
          };
        };
      };
    };
  };
}
