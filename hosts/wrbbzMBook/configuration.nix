{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    jq
    k9s
    kubectl
    kubelogin-oidc
    nodejs
    pass
    pulumi-bin
    telepresence2
  ];
}
