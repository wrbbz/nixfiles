{ pkgs, ... }: {

  networking = {
    # useDHCP = true;
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 80 443 4000];
  };

  services.resolved.enable = true;

  # Remote x86_64-linux builder for wrbbzMBook (nixpkgs-review).
  # trusted-users is required so pushed build inputs don't fail
  # with "path lacks a valid signature".
  nix.settings.trusted-users = [ "wrbbz" ];
  users.users.wrbbz.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKJ894D56hofWt5IxootnovZWjIJ/xwxJ9fdtvTlc2d3 nix remote builds"
  ];

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
