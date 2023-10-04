{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    slack.enable = mkOption {
      description = "Enable slack";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.slack.enable {
    environment.systemPackages = with pkgs; [ slack ];
    nixpkgs.allowUnfreePackages = [ "slack" ];
  };
}
