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
    # pwgen 2.08 uses K&R C declarations, incompatible with C23.
    # Remove once https://github.com/NixOS/nixpkgs/issues/511329 is resolved.
    nixpkgs.overlays = [
      (final: prev: {
        pwgen = prev.pwgen.overrideAttrs (old: {
          configureFlags = (old.configureFlags or [ ]) ++ [ "CFLAGS=-std=gnu17" ];
        });
      })
    ];
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
      launchd.agents.gpg-agent = mkIf (pkgs.stdenv.isDarwin) {
        enable = true;
      };
    };
    environment.systemPackages = with pkgs; [ pwgen ];
  };
}
