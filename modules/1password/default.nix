{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    one-password.enable = mkOption {
      description = "Enable 1password";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.one-password.enable {
    nixpkgs.allowUnfreePackages = [ "1password" "1password-gui" "1password-cli" ];
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      # Certain features, including CLI integration and system authentication support,
      # require enabling PolKit integration on some desktop environments (e.g. Plasma).
      polkitPolicyOwners = [ "wrbbz" ];
    };
  };
}
