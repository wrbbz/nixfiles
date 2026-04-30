# configuration in this file is shared by all hosts

{ pkgs, ... }: {

  # sops-nix: use SSH host key for system-level secret decryption (runs as root, no passphrase)
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Allow user wrbbz to read the SSH host key for home-manager sops activation
  users.groups.sops-secrets = {};
  systemd.tmpfiles.rules = [
    "z /etc/ssh/ssh_host_ed25519_key 0640 root sops-secrets -"
  ];

  users.users = {
    root = {
      initialHashedPassword = "$6$o.yY8ETd3VmTj2n4$APQjNsOuNsbheay7H4CEg7hbG7TfISDnR/mGuz6xuPQr9HpKm8Nx0CEHwLmFhDD6ZdNQ/CmZvvz48JmQhgfoi/";
      openssh.authorizedKeys.keys = [ "sshKey_placeholder" ];
    };
  };

  users.users.wrbbz = {
    initialHashedPassword = "!";
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "sops-secrets"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  home-manager.users.wrbbz = {
    home.username = "wrbbz";
    home.stateVersion = "26.05";
  };

  ## enable ZFS auto snapshot on datasets
  ## You need to set the auto snapshot property to "true"
  ## on datasets for this to work, such as
  # zfs set com.sun:auto-snapshot=true rpool/nixos/home
  services.zfs = {
    autoSnapshot = {
      enable = false;
      flags = "-k -p --utc";
      monthly = 48;
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  services.openssh = {
    enable = true;
    settings = { PasswordAuthentication = false; };
  };

  boot.zfs.forceImportRoot = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.git.enable = true;

  security = {
    doas ={
      enable = true;
      extraRules = [{
        users = ["wrbbz"];
        persist = true;
      }];
    };
    sudo.enable = false;
    polkit.enable = true;
  };

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      cryptsetup
    ;
  };

  fonts = {
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.hack
      noto-fonts-color-emoji
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Hack" ];
        sansSerif = [ "Hack" ];
        monospace = [ "Fira" ];
        emoji = [ "NotoColorEmoji" ];
      };
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  networking = {
    nftables.enable = true;
    firewall.enable = true;
  };
}
