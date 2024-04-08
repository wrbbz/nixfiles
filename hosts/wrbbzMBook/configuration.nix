{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    pass
    pulumi-bin
  ];
}
