{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    kubernetes.enable = mkOption {
      description = "Collection of kubernetes tools";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.kubernetes.enable {
    environment.systemPackages = with pkgs; [
      k9s
      kubectl
      kubelogin-oidc
    ];
  };
}
