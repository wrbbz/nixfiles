{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    k9s
    kubectl
    kubelogin-oidc
    nodejs
    pass
    pulumi-bin
  ];
}
