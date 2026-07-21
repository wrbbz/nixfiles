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
      cargo
      clippy
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
      rust-analyzer
      rustc
      rustfmt
      usql
      yarn
      yq-go
    ] ++ (lib.optionals pkgs.stdenv.isDarwin [
      less
    ]);
  };
}
