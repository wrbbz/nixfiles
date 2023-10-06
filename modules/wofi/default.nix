{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    wofi.enable = mkOption {
      description = "Enable my customized wofi (a launcher/menu for wayland)";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.wofi.enable {
    home-manager.users.wrbbz = {
      programs.wofi = {
        enable = true;
        style = ''
          window {
            margin: 0px;
            border: 1px solid #282828;
            border-radius: 10px;
            background-color: #7c6f64;
          }

          #input {
            margin: 5px;
            border: none;
            border-radius: 10px;
            color: #fbf1c7;
            background-color: #928374;
          }

          #inner-box {
            margin: 5px;
            border: none;
            background-color: #504945;
            border-radius: 10px;
          }

          #outer-box {
            margin: 5px;
            border: none;
            background-color: #504945;
            border-radius: 10px;
          }

          #scroll {
            margin: 5px;
            border: none;
          }

          #text {
            margin: 5px;
            border: none;
            color: #fbf1c7;
          }

          #entry:selected {
            background-color: #a89984;
            border-radius: 10px;
          }
        '';
      };
    };
  };
}
