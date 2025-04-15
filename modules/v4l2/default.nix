{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    v4l2.enable = mkOption {
      description = "Enable my customized v4l2";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.v4l2.enable {
    boot.extraModulePackages = with config.boot.kernelPackages;
    [ v4l2loopback.out ];
    boot.kernelModules = [
      "v4l2loopback"
    ];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="Virtual Camera" exclusive_caps=1
    '';
  };
}
