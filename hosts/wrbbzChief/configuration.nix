# configuration in this file only applies to exampleHost host.

{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    newSession = true;
    terminal = "tmux-direct";
  };
  services.emacs.enable = false;

  environment.systemPackages = with pkgs; [
    figlet
    fira
    fira-code
    fira-mono
    firefox
    go
    k9s
    kubectl
    mpv
    nodejs
    obs-studio
    pandoc
    pulumi-bin
    ripgrep
    tdesktop
    tmate
    trivy
    wget
  ];

  programs.wireshark.enable = true;
}
