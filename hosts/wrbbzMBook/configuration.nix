{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    glow
    jq
    k9s
  ];
}
