{ pkgs, ... }: {

  networking = {
    hostName = "wrbbzMBook";
  };

  environment.systemPackages = with pkgs; [
    cloudflared
    telegram-desktop
    trivy
    zola
  ];
}
