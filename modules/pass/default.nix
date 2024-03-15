{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkDefault mkOption;
in {
  options.my-config = {
    pass.enable = mkOption {
      description = "Enable my customized pass";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.pass.enable {
    home-manager.users.wrbbz = {
      programs.password-store = {
        enable = true;
        package = pkgs.pass-wayland.withExtensions (exts: [ exts.pass-otp ]);
	settings = {
	  PASSWORD_STORE_DIR = "/home/wrbbz/.password-store";
	};
      };

      programs.gpg = {
        enable = true;
      };

      services.gpg-agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-curses;
      };
    };
  };
}
