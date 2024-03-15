{ pkgs, ... }: {

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  networking = {
    # useDHCP = true;
    networkmanager.enable = true;
  };

  services.resolved.enable = true;

  programs.tmux = {
    enable = true;
    newSession = true;
    terminal = "tmux-direct";
  };
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
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = with pkgs; [
    cider
    droidcam
    fira
    fira-code
    fira-mono
    firefox
    glow
    go
    jq
    k9s
    kooha
    kubectl
    kubelogin-oidc
    libimobiledevice
    mpv
    nix-prefetch-github
    nodejs
    # obs-studio
    # obs-studio-plugins.obs-backgroundremoval
    pandoc
    pulumi-bin
    tdesktop
    telepresence2
    tessen
    trivy
    yarn
  ];

  programs.wireshark.enable = true;
}
