{ config, lib, pkgs, inputs, isDarwin ? false, ... }:
let inherit (lib) types mkIf mkOption;
in {
  options.my-config = {
    do-next.enable = mkOption {
      description = "Enable do-next Jira task picker";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.do-next.enable {
    home-manager.users.wrbbz.home.packages = [
      inputs.do-next.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
