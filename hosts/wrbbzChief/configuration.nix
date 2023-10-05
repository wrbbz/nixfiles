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

  environment.systemPackages = with pkgs; [
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
    mako
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
    tmate
    trivy
    wget
    wofi
  ];

  programs.wireshark.enable = true;
}
