{ config, lib, pkgs, ... }:
let
  inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    telegram.enable = mkOption {
      description = "Enable Telegram";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.telegram.enable (lib.mkMerge [
    (lib.mkIf pkgs.stdenv.isLinux {
      home-manager.users.wrbbz.home.packages = [ pkgs.telegram-desktop ];
    })

    (lib.mkIf pkgs.stdenv.isDarwin {
      homebrew.masApps.Telegram = 747648890;
    })
  ]);
}
