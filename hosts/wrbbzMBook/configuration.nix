{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    k9s
    kubectl
    kubelogin-oidc
    pass
    pulumi-bin
  ];
}
