{ lib, pkgs, ... }: {
  home-manager.users.wrbbz =
    # Function form to access config.home.homeDirectory
    { config, ... }:
    {
      home.packages = with pkgs; [
        age
        sops
      ];

      sops.age = if pkgs.stdenv.isLinux then {
        # Age identity derived from the SSH host key at boot by the
        # sops-age-key-wrbbz service (see configuration.nix)
        keyFile = "/var/lib/sops-wrbbz/keys.txt";
      } else {
        # age key generated with age-keygen, used for both activation and editing
        keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };
    };
}
