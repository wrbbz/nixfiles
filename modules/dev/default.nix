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
      biome
      cobra-cli
      devbox
      dive
      gnumake
      go
      gonzo
      jq
      just
      jwt-cli
      nodejs
      pulumi-bin
      usql
      yarn
      yq-go
    ];
  };
}
