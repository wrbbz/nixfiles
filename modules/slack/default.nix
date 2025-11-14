{ config, lib, pkgs, ... }:
let
  inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    slack.enable = mkOption {
      description = "Enable slack";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.slack.enable {
    home-manager.users.wrbbz = {
      home.packages = with pkgs; [
        (if pkgs.stdenv.isLinux then
          (slack.overrideAttrs (old: {
            nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
            # append to postInstall to avoid clobbering upstream phases
            postInstall = (old.postInstall or "") + ''
              rm -f $out/bin/slack

              makeWrapper $out/lib/slack/slack $out/bin/slack \
                --prefix XDG_DATA_DIRS : $GSETTINGS_SCHEMAS_PATH \
                --prefix PATH : ${lib.makeBinPath [ pkgs.xdg-utils ]} \
                --add-flags "--ozone-platform=wayland --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer"
            '';
          }))
        else
          slack)
      ];

      # Disable Slack auto-update so it stops trying to install a privileged helper
      targets.darwin.defaults = mkIf pkgs.stdenv.isDarwin {
        "com.tinyspeck.slackmacgap" = { AutoUpdate = false; };
      };
    };

    nixpkgs.allowUnfreePackages = [ "slack" ];
  };
}
