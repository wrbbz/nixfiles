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
    security.acme = {
      acceptTerms = true;
      defaults.email = "me+acme@wrb.bz";
      certs."${config.my-config.jellyfin.domain}" = {
        dnsProvider = "cloudflare";
        environmentFile = "/opt/certs/cf/acme.credentials";
        group = config.services.nginx.group;
      };
    };
    services = {
      jellyfin = {
        enable = true;
        openFirewall = true;
      };
      nginx = {
        virtualHosts."${config.my-config.jellyfin.domain}" = {
          forceSSL = true;
          sslCertificate = "/var/lib/acme/${config.my-config.jellyfin.domain}/cert.pem";
          sslCertificateKey = "/var/lib/acme/${config.my-config.jellyfin.domain}/key.pem";
          locations."/" = {
            proxyPass = "http://localhost:${toString config.my-config.jellyfin.port}";
          };
        };
      };
    };
  };
}
