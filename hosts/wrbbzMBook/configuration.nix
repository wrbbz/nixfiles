{ pkgs, ... }: {

  networking = {
    hostName = "wrbbzMBook";
  };

  environment.systemPackages = with pkgs; [
    cloudflared
    tailscale
    trivy
    zola
  ];
}
