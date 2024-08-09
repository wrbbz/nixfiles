{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    pass.enable = mkOption {
      description = "Enable my customized pass";
      type = types.bool;
      default = false;
    };
    pass.isDarwin = mkOption {
      description = "Flag for specifiying wether the current host is darwin system or not";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.pass.enable {
    home-manager.users.wrbbz = {
      programs.password-store = {
        enable = true;
        package = if config.my-config.pass.isDarwin
        then
          pkgs.pass.withExtensions (exts: [ exts.pass-otp ])
        else
          pkgs.pass-wayland.withExtensions (exts: [ exts.pass-otp ]);
      };

      programs.gpg = {
        enable = true;
      };

      services.gpg-agent = mkIf (!config.my-config.pass.isDarwin) {
        enable = true;
        pinentryPackage = pkgs.pinentry-curses;
      };
    };
    environment.systemPackages = with pkgs; [ pwgen ];
  };
}
