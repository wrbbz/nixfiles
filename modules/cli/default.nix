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
      jira-cli-go
      ipcalc
      pwgen
      nh
      nix-prefetch
      nix-tree
      nixpkgs-review
      nvd # https://gitlab.com/khumba/nvd
      ranger
      ripgrep
      tmate
      wget
      whois
      yazi
      yt-dlp
    ]
    ++(pkgs.lib.optionals pkgs.stdenv.isLinux [
      hdparm
      pw-volume
    ]);
  };
}
