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
    nix-homebrew.darwinModules.nix-homebrew = {
      nix-homebrew = {
        inherit user;
        enable = true;
        taps = {
          "homebrew/homebrew-core" = homebrew-core;
          "homebrew/homebrew-cask" = homebrew-cask;
          "homebrew/homebrew-bundle" = homebrew-bundle;
        };
        mutableTaps = false;
        autoMigrate = true;
      };
    };
    homebrew = {
      # This is a module from nix-darwin
      # Homebrew is *installed* via the flake input nix-homebrew
      enable = true;
      casks = pkgs.callPackage ./casks.nix {};
    };
  };
}
