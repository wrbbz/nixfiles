{ config, lib, pkgs, homebrew-core, homebrew-cask, homebrew-bundle, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    brew.enable = mkOption {
      description = "Collection of brew tools";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.brew.enable {
    homebrew = {
      # This is a module from nix-darwin
      # Homebrew is *installed* via the flake input nix-homebrew
      enable = true;
      brews = pkgs.callPackage ./brews.nix {};
      casks = pkgs.callPackage ./casks.nix {};
    };
  };
}
