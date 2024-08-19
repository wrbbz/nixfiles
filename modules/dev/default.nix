{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    dev.enable = mkOption {
      description = "Collection of dev tools";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.dev.enable {
    environment.systemPackages = with pkgs; [
      cloudflared
      devbox
      dive
      go
      jq
      nodejs
      pulumi-bin
      usql
      yarn
    ];
  };
}
