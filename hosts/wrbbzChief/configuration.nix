# configuration in this file only applies to exampleHost host.

{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    newSession = true;
    terminal = "tmux-direct";
  };
  services.emacs.enable = false;

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
