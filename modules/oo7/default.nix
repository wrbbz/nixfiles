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
