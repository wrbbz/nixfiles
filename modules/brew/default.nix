{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    brew.enable = mkOption {
      description = "Collection of brew tools";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.git.enable {
    homebrew = {
      # This is a module from nix-darwin
      # Homebrew is *installed* via the flake input nix-homebrew
      enable = true;
      casks = pkgs.callPackage ./casks.nix {};
    };
  };
