{ pkgs, ... }: {

  networking = {
    # useDHCP = true;
    networkmanager.enable = true;
    extraHosts = ''
    51.89.41.40 3d.cs.money
    '';
  };

  # services.resolved.enable = true;

  programs.tmux = {
    enable = true;
    newSession = true;
    terminal = "tmux-direct";
  };
  programs.ssh.startAgent = true;
  services.emacs.enable = false;

  # environment.etc = {
  #   "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
  #     bluez_monitor.properties = {
  #       ["bluez5.enable-sbc-xq"] = true,
  #       ["bluez5.enable-msbc"] = true,
  #       ["bluez5.enable-hw-volume"] = true,
  #       ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
  #     }
  #   '';
  # };

  # Allows connect iOS devices
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  programs.gamescope = {
    enable = false;
    capSysNice = true;
  };

  environment.systemPackages = with pkgs; [
    cassette
    cider
    droidcam
    fira
    fira-code
    fira-mono
    glow
    kooha
    libimobiledevice
    mpv
    # obs-studio
    # obs-studio-plugins.obs-backgroundremoval
    pandoc
    telegram-desktop
    tessen
    trivy
    # webcord
  ];

  programs.wireshark.enable = true;
}
