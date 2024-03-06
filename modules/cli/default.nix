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
      bottom
      dig
      figlet
      file
      glab
      hdparm
      ipcalc
      pwgen
      pw-volume
      nix-tree
      nvd # https://gitlab.com/khumba/nvd
      ranger
      ripgrep
      tmate
      wget
      whois
      yt-dlp
    ];
  };
}
