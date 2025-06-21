{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    acme.enable = mkOption {
      description = "Enable acme with lego";
      type = types.bool;
      default = false;
    };
    acme.domain = mkOption {
      description = "Domain for ACME challenge";
      type = types.str;
      default = "wrb.bz";
    };
  };

  config = mkIf config.my-config.acme.enable {
    security.acme = {
      acceptTerms = true;
      defaults.email = "me+acme@wrb.bz";
      certs."${config.my-config.acme.domain}" = {
        domain = "*.${config.my-config.acme.domain}";
        dnsProvider = "cloudflare";
        environmentFile = "/opt/certs/cf/acme.credentials";
        group = config.services.nginx.group;
      };
    };
  };
}
