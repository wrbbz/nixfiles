# configuration in this file is shared by all hosts

{ pkgs, ... }: {
  # Enable NetworkManager for wireless networking,
  # You can configure networking with "nmtui" command.
  networking.useDHCP = true;
  networking.networkmanager.enable = false;

  users.users = {
    root = {
      initialHashedPassword = "$6$hCf/1CGUhM2EGsy7$lbzBtxItrcXOLrAbvVfM44LagA7Dn0MgP51fWWnLvtQVHwNbAadARCSyhjKH//NlkRg.7e9z6LdwVsg65UGag0";
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
      (nerdfonts.override { fonts = [ "FiraCode" "Hack" ];})
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
