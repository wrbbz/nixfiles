{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    yamusic.enable = mkOption {
      description = "Enable yandex-music";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.yamusic.enable {
    environment.systemPackages = with pkgs; [
      yandex-music
    ];
    nixpkgs.allowUnfreePackages = [ "yandex-music" ];
  };
}
