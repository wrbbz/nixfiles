{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    telepresence.enable = mkOption {
      description = "Enable telepresence with doas2sudo script";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.telepresence.enable {
    home-manager.users.wrbbz = {
      home.packages = with pkgs; [
        telepresence2
      ]
      ++(pkgs.lib.optionals pkgs.stdenv.isLinux [
        (writeShellApplication {
          name = "sudo";
          # runtimeInputs = [
          #   security.doas.enable
          # ];
          text = (builtins.readFile ./sudo2doas.sh);
        })
      ]);
    };
  };
}
