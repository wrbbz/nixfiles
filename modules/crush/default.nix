{ config, lib, pkgs, networking, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    crush.enable = mkOption {
      description = "Enable crush";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.crush.enable {
    programs.crush.enable = true;

    nixpkgs.allowUnfreePackages = [ "crush" ];
  };
}

