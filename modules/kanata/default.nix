{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    kanata.enable = mkOption {
      description = "Installs kanata for keyboard mapping";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.kanata.enable {
    environment.systemPackages = with pkgs; [
      kanata
    ];
  };
}
