{ pkgs, ... }: {

  networking = {
    hostName = "wrbbzMBook";
  };

  # nix-darwin's linux-builder module writes this file without IdentitiesOnly,
  # so ssh (as root via sudo, which keeps SSH_AUTH_SOCK) offers every agent key
  # first and hits the builder's MaxAuthTries before reaching the builder key.
  environment.etc."ssh/ssh_config.d/100-linux-builder.conf".text = pkgs.lib.mkForce ''
    Host linux-builder
      User builder
      Hostname localhost
      HostKeyAlias linux-builder
      Port 31022
      IdentityFile /etc/nix/builder_ed25519
      IdentitiesOnly yes
  '';

  nix = {
    distributedBuilds = true;

    # aarch64-linux builder VM (QEMU + Hypervisor.framework), managed by launchd.
    # Start/stop on demand:
    #   sudo launchctl bootstrap system /Library/LaunchDaemons/org.nixos.linux-builder.plist
    #   sudo launchctl bootout system/org.nixos.linux-builder
    linux-builder = {
      enable = true;
      config = {
        virtualisation = {
          cores = 6;
          darwin-builder = {
            memorySize = 8 * 1024; # MiB
            diskSize = 50 * 1024; # MiB; can only grow without wiping /var/lib/darwin-builder
          };
        };
      };
    };

    buildMachines = [
      {
        hostName = "192.168.8.16"; # wrbbzGM (LAN)
        sshUser = "wrbbz";
        sshKey = "/Users/wrbbz/.ssh/wrbbzGM-builder";
        systems = [ "x86_64-linux" ];
        protocol = "ssh-ng";
        maxJobs = 8;
        supportedFeatures = [ "big-parallel" "kvm" "nixos-test" ];
      }
    ];

    # Remote builders fetch dependencies from cache.nixos.org themselves
    # instead of receiving them from this machine
    settings.builders-use-substitutes = true;
  };

  # The nix daemon (root) makes the builder ssh connections, so the host key
  # must be trusted system-wide, not just in ~/.ssh/known_hosts.
  # wrbbzGM's sshd only serves its RSA host key: the ed25519 key is
  # group-readable for sops (see tmpfiles rule in configuration.nix),
  # which makes sshd refuse to load it.
  programs.ssh.knownHosts = {
    wrbbzGM-ed25519 = {
      hostNames = [
        "192.168.8.16"
      ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPYcgHY6BOY3zw9V6ZdjPN3DJbtZnEefs7ZozkH3jkAy";
    };
  };

  environment.systemPackages = with pkgs; [
    cloudflared
    podman-compose
    qmk
    trivy
    zola
  ];
}
