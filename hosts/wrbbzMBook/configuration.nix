{ pkgs, ... }: {

  networking = {
    hostName = "wrbbzMBook";
  };

  environment.systemPackages = with pkgs; [
    cloudflared
    podman-compose
    qmk
    trivy
    zola
  ];
}
