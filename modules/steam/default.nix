{ config, lib, pkgs, networking, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    steam.enable = mkOption {
      description = "Enable steam";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.steam.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };

    programs.gamemode.enable = true;

    nixpkgs.allowUnfreePackages = [
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
    ];

    # local share
    networking.firewall.allowedTCPPorts = [ 24070 ];
  };
}
