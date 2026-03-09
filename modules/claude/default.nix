{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    claude.enable = mkOption {
      description = "Enable claude-code";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.claude.enable {
    home-manager.users.wrbbz = {
      home.packages = with pkgs; [
        claude-code
      ];
    };
    nixpkgs.allowUnfreePackages = [ "claude-code" ];
  };
}
