# configuration in this file is shared by all hosts

{ pkgs, ... }: {
  # Enable NetworkManager for wireless networking,
  # You can configure networking with "nmtui" command.
  networking.useDHCP = true;
  networking.networkmanager.enable = false;

  users.users = {
    root = {
      initialHashedPassword = "$6$XlS5gk5Nbc8u2Kfr$f47mT6DH5c/rlKxsQltQpHF0xFu5xxlopidrJOtDq8yVvBXOVH40yU24Kg5KlCbIAiyL/xzSC3362VahvNyue1";
      openssh.authorizedKeys.keys = [ "sshKey_placeholder" ];
    };
  };

  users.users.wrbbz = {
    initialHashedPassword = "!";
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  home-manager.users.wrbbz = {
    home.username = "wrbbz";
    home.stateVersion = "23.05";
  };

  ## enable GNOME desktop.
  ## You need to configure a normal, non-root user.
  # services.xserver = {
  #  enable = true;
  #  desktopManager.gnome.enable = true;
  #  displayManager.gdm.enable = true;
  # };

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
    doas.enable = true;
    sudo.enable = false;
  };

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      cryptsetup
      jq # other programs
    ;
  };

  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "Hack" ]; })
      noto-fonts-emoji
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

  networking.nftables.enable = true;
  networking.firewall.enable = true;
}
