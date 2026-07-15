{ config, lib, inputs, ... }:
let
  inherit (lib) types mkIf mkOption;
  cfg = config.my-config.nixflix;
  sec = name: config.sops.secrets.${name}.path;
in
{
  options.my-config.nixflix = {
    enable = mkOption {
      description = "Enable nixflix media stack (jellyfin + arr suite)";
      type = types.bool;
      default = false;
    };
    domain = mkOption {
      description = "Base domain for nixflix services (each service gets <service>.<domain>)";
      type = types.str;
      default = "wrb.bz";
    };
    mediaDir = mkOption {
      description = "Root directory for the media library";
      type = types.path;
      default = "/media";
    };
    downloadsDir = mkOption {
      description = "Root directory for download clients";
      type = types.path;
      default = "/media/downloads";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = lib.genAttrs [
      "jellyfin-api-key"
      "jellyfin-admin-password"
      "radarr-api-key"
      "sonarr-api-key"
      "prowlarr-api-key"
      "arr-username"
      "arr-password"
    ] (_: { sopsFile = ../../secrets/nixflix.yaml; });

    nixflix = {
      enable = true;
      mediaDir = cfg.mediaDir;
      downloadsDir = cfg.downloadsDir;

      nginx = {
        enable = true;
        domain = cfg.domain;
        forceSSL = true;
        # Reuses security.acme.certs."${domain}" provisioned by the acme module.
        enableACME = true;
      };

      jellyfin = {
        enable = true;
        apiKey = { _secret = sec "jellyfin-api-key"; };
        users.wrbbz = {
          password = { _secret = sec "jellyfin-admin-password"; };
          policy.isAdministrator = true;
          mutable = true;
        };
        libraries."Movies" = {
          collectionType = "movies";
          paths = [ "${cfg.mediaDir}/movies" ];
          saveLocalMetadata = false;
        };
        libraries."TV Shows" = {
          collectionType = "tvshows";
          paths = [ "${cfg.mediaDir}/tv" ];
          saveLocalMetadata = false;
        };

        plugins."Trakt".package = inputs.nixflix.lib.jellyfinPlugins.fromRepo {
          version = "29.0.0.0";
          repository = "Jellyfin Stable";
          hash = "sha256-78mT119uZA0/nSGDsnjfbE8j+RiEBmOOk6RBwSzQFpE=";
        };
      };

      radarr = {
        enable = true;
        config.apiKey = { _secret = sec "radarr-api-key"; };
        config.hostConfig.username = { _secret = sec "arr-username"; };
        config.hostConfig.password = { _secret = sec "arr-password"; };
      };

      sonarr = {
        enable = true;
        config.apiKey = { _secret = sec "sonarr-api-key"; };
        config.hostConfig.username = { _secret = sec "arr-username"; };
        config.hostConfig.password = { _secret = sec "arr-password"; };
      };

      prowlarr = {
        enable = true;
        config.apiKey = { _secret = sec "prowlarr-api-key"; };
        config.hostConfig.username = { _secret = sec "arr-username"; };
        config.hostConfig.password = { _secret = sec "arr-password"; };
        # Names must match Prowlarr's indexer schema names exactly.
        config.indexers = [
          {
            name = "The Pirate Bay";
            baseUrl = "https://thepiratebay.org/";
          }
          { name = "NoNaMe Club"; }
          { name = "1337x"; }
          { name = "EZTV"; }
          { name = "YTS"; }
        ];
      };

      torrentClients.qbittorrent = {
        enable = true;
        # arr services connect from localhost — no credentials needed.
        # External WebUI access (qbittorrent.wrb.bz) still requires auth set via the UI.
        serverConfig.Preferences.WebUI.LocalHostAuth = false;
      };
    };
  };
}
