{ config, lib, pkgs, inputs, isDarwin ? false, ... }:
let inherit (lib) types mkIf mkOption;
in {
  options.my-config = {
    sidra.enable = mkOption {
      description = "Enable Sidra Apple Music client";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.sidra.enable {
    home-manager.users.wrbbz.home.packages = [
      inputs.sidra.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
