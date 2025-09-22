{ config, lib, pkgs, inputs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    firefox.enable = mkOption {
      description = "Enable Firefox";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.firefox.enable {
    home-manager.users.wrbbz = {
      imports = [ inputs.textfox.homeManagerModules.default ];

      programs.firefox = {
        enable = true;
        languagePacks = [ "ru" "en-US" ];
        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          EnableTrackingProtection = {
            Value= true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          DisableFirefoxAccounts = true;
          DisableAccounts = true;
          DontCheckDefaultBrowser = true;
          DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
          DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
          SearchBar = "unified"; # alternative: "separate"

             /* ---- EXTENSIONS ---- */
          # Check about:support for extension/add-on ID strings.
          # Valid strings for installation_mode are "allowed", "blocked",
          # "force_installed" and "normal_installed".
          ExtensionSettings = {
            "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
            # Privacy Badger:
            "jid1-MnnxcxisBPnSXQ@jetpack" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
              installation_mode = "force_installed";
            };
            # FoxyProxy:
            "foxyproxy@eric.h.jung" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/foxyproxy-standard/latest.xpi";
              installation_mode = "force_installed";
            };
            # BitWarden:
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
              installation_mode = "force_installed";
            };
            # Sideberry
            "{3c078156-979c-498b-8990-85f7987dd929}" = {
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
              installation_mode = "force_installed";
            };
          };
        };
      };

      textfox = {
        enable = true;
        profile = "default-release";
        config = {
          displayHorizontalTabs = false;
          displayWindowControls = false;
          displayNavButtons = true;
          displayUrlbarIcons = true;
          displaySidebarTools = true;
          displayTitles = true;
        };
      };
    };
  };
}
