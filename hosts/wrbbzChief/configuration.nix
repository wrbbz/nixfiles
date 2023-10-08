{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    newSession = true;
    terminal = "tmux-direct";
  };
  services.emacs.enable = false;

  # Enable sound.
  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  environment.etc = {
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
  };

  # Allows connect iOS devices
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  environment.systemPackages = with pkgs; [
    bottom
    droidcam
    figlet
    fira
    fira-code
    fira-mono
    firefox
    glab
    go
    k9s
    kubectl
    kubelogin-oidc
    libimobiledevice
    mpv
    nodejs
    obs-studio
    pandoc
    pulumi-bin
    pwgen
    ranger
    ripgrep
    tdesktop
    telepresence2
    tessen
    tmate
    trivy
    wget
    yarn
  ];

  programs.wireshark.enable = true;
}
