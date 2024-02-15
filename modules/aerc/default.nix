{ config, lib, pkgs, ... }:

let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    aerc.enable = mkOption {
      description = "Enable my customized aerc";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.aerc.enable {
    home-manager.users.wrbbz = {
      programs.aerc = {
        enable = true;
      };
    };
  };
}
