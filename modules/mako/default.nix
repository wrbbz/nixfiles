{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    mako.enable = mkOption {
      description = "Enable my customized mako (notifications for wayland)";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.mako.enable {
    home-manager.users.wrbbz = {
      services.mako = {
        enable = true;
        package = pkgs.mako;
        anchor = "top-right";
        borderRadius=15;
        backgroundColor="#7c6f64";
        borderColor="#f9f5d7";
        textColor="#f9f5d7";
        font="Fira Code";
        icons=true;
        progressColor="#83a598";
        maxVisible=5;
        markup=true;
        defaultTimeout=5000;
        sort="-time";
      };
    };
  };
}
