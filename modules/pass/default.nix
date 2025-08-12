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
        package = if pkgs.stdenv.isDarwin
        then
          pkgs.pass.withExtensions (exts: [ exts.pass-otp ])
        else
          pkgs.pass-wayland.withExtensions (exts: [ exts.pass-otp ]);
      };

      programs.gpg = {
        enable = true;
      };

      services.gpg-agent = mkIf (pkgs.stdenv.isLinux) {
        enable = true;
        pinentry.package = pkgs.pinentry-curses;
      };
      launchd.gpg-agent = mkIf (pkgs.stdenv.isDarwin) {
        enable = true;
        pinentry.package = pkgs.pinentry-curses;
      };
    };
    environment.systemPackages = with pkgs; [ pwgen ];
  };
}
