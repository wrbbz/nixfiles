{ config, lib, pkgs, ... }:
let inherit (lib) types mkIf mkOption;
in {
  options.my-config = {
    oo7.enable = mkOption {
      description = "Enable oo7 as the Secret Service (org.freedesktop.secrets) keyring";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.oo7.enable {
    # pam_oo7 0.6.0 delivers the password to the daemon from a detached thread
    # that forks a helper child out of the PAM caller and returns at once.
    # util-linux `login` then forks the user's shell and reaps *any* child
    # with waitpid(-1), so the helper gets stolen from the module ("Failed to
    # wait for child process: No child processes") and login tears the session
    # down a few ms after it started: the tty flashes and drops back to getty.
    # Upstream fixed this by delivering synchronously (commit e91b98a, after
    # 0.6.0). Backport it until nixpkgs ships a release that contains it.
    nixpkgs.overlays = [
      (final: prev: {
        oo7-pam = prev.oo7-pam.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./pam-deliver-before-return.patch ];
        });
      })
    ];

    # oo7-daemon stores the keyring in ~/.local/share/keyrings, encrypted with
    # the login password. pam_oo7 on the `login` service (wired by services.oo7)
    # forwards the password typed at the tty so the keyring is unlocked for the
    # whole session. Fingerprint/U2F logins give PAM no password, so they can
    # not unlock it: keep the tty login on password, put biometrics on
    # doas/hyprlock instead.
    services.oo7.enable = true;

    # Make libsecret-based apps (Electron, Chromium, git-credential-libsecret)
    # find the daemon without needing GNOME around.
    environment.systemPackages = with pkgs; [ libsecret ];
  };
}
