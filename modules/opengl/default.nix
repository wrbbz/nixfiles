{ config, lib, ... }:
let inherit (lib) types mkIf mkOption;
in {
  options.my-config = {
    opengl.enable = mkOption {
      description = "Enable opengl with some extras";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.opengl.enable {
    hardware.graphics.enable = true;
  };
}
