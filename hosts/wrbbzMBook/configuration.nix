{ pkgs, ... }: {

  networking = {
    hostName = "wrbbzMBook";
  };

  environment.systemPackages = with pkgs; [
    go
    jq
    k9s
    kubectl
    kubelogin-oidc
    nodejs
    pass
    pulumi-bin
    telepresence2
    zola
  ];
}
