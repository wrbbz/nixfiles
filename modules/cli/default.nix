{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    cli.enable = mkOption {
      description = "Collection of cli tools";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.cli.enable {
    environment.systemPackages = with pkgs; [
      figlet
      bottom
      glab
      hdparm
      joshuto
      pulsemixer
      pwgen
      pw-volume
      ranger
      ripgrep
      tmate
      wget
      yt-dlp
    ];
  };
}
