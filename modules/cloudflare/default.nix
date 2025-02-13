{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption mkMerge;
in {
  options.my-config = {
    cloudflare.enable = mkOption {
      description = "Enable cloudflare";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (config.my-config.cloudflare.enable) (mkMerge [
    {
      environment.systemPackages = with pkgs; [
        cloudflared
      ];
    }
    (mkIf pkgs.stdenv.isLinux {
      nixpkgs.allowUnfreePackages = [
        "cloudflare-warp"
      ];
      services.cloudflare-warp = {
        enable = true;
      };
    })
  ]);
}
