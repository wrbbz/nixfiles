{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkOption;
in {
  options.my-config = {
    fingerprint.enable = mkOption {
      description = "Enable fprintd with the Chipsailing CS9711 (2541:0236) community driver for doas and hyprlock";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.fingerprint.enable {
    # Upstream libfprint lists 2541:0236 as "known unsupported". archeYR's fork
    # rebases the cs9711 driver plus the sigfm (OpenCV) matcher on top of each
    # libfprint release until both land upstream. Replacing `libfprint` globally
    # makes fprintd pick it up.
    nixpkgs.overlays = [
      (final: prev: {
        libfprint = prev.libfprint.overrideAttrs (old: {
          pname = "libfprint-cs9711";
          version = "1.94.10-unstable-2026-02-17";
          src = prev.fetchFromGitHub {
            owner = "archeYR";
            repo = "libfprint-CS9711";
            rev = "02b285c9703c38d308fbe47a3c566ef1e7f883ca";
            hash = "sha256-QGrBNqbRNqLZIURI66xkenlQamNW+DQU4WS+CLN4zM8=";
          };
          # The fork's sigfm matcher is C++ on top of OpenCV; its unit tests need doctest.
          buildInputs = (old.buildInputs or [ ]) ++ [ prev.opencv4 prev.doctest ];
          # meson executes tests/unittest_inspector.py at configure time. nixpkgs
          # only gets python3 into PATH via nativeInstallCheckInputs, which the
          # doInstallCheck = false below drops, so patchShebangs could not
          # resolve `/usr/bin/env python3` and meson failed to exec the script.
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.python3 ];
          # nixpkgs patches shebangs in a test runner the fork does not ship.
          postPatch = ''
            patchShebangs tests/*.py tests/*.sh
          '';
          # Upstream's test suite does not know about the cs9711 driver.
          doInstallCheck = false;
          meta = old.meta // {
            homepage = "https://github.com/archeYR/libfprint-CS9711";
            description = "libfprint with the community Chipsailing CS9711 driver";
          };
        });
      })
    ];

    services.fprintd = {
      enable = true;
      # Do not add pam_fprintd to every PAM service (login, sshd, polkit, ...).
      # tty login stays password-only so pam_oo7 can unlock the keyring.
      enablePam = false;
    };

    # doas: "Place your finger on the reader" first, password after a timeout.
    security.pam.services.doas.fprintAuth = true;

    # hyprlock talks to fprintd over D-Bus itself, so password and finger are
    # accepted at the same time. Keep pam_fprintd off its PAM service, otherwise
    # both would fight over the device.
    security.pam.services.hyprlock.fprintAuth = false;
    home-manager.users.wrbbz.programs.hyprlock.settings.auth.fingerprint = {
      enabled = true;
      ready_message = "(Scan fingerprint to unlock)";
      present_message = "Scanning fingerprint";
    };
  };
}
