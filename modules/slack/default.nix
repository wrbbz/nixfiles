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
    environment.systemPackages = with pkgs; [
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

    nixpkgs.allowUnfreePackages = [ "slack" ];
  };
}
