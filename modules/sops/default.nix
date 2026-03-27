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
        # SSH host key is group-readable (sops-secrets group), no passphrase
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      } else {
        # age key generated with age-keygen, used for both activation and editing
        keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      };
    };
}
