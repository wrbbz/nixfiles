{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    discord.enable = mkOption {
      description = "Enable discord";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.discord.enable {
    environment.systemPackages = with pkgs; [ discord ];
    nixpkgs.allowUnfreePackages = [ "discord" ];
  };
}
