{ config, lib, pkgs, ... }:
let
  inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    joshuto.enable = mkOption {
      description = "Enable jushuto";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.joshuto.enable {
    home-manager.users.wrbbz = {
      programs.joshuto = {
        enable = true;
      };
    };
  };
}
