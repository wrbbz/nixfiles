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

  config = mkIf config.my-config.telegram.enable {
    home-manager.users.wrbbz = {
      home.packages = with pkgs; [
        telegram-desktop
      ];
    };
  };
}
