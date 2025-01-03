{ pkgs, ... }: {

  networking = {
    # useDHCP = true;
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 80 443];
  };

  services.resolved.enable = true;

  services.nginx.enable = true;

  programs.tmux = {
    enable = true;
    newSession = true;
    terminal = "tmux-direct";
  };
  services.emacs.enable = false;

  environment.systemPackages = with pkgs; [
    fira
    fira-code
    fira-mono
    glow
    kooha
    tessen
    trivy
    webcord
  ];
}
