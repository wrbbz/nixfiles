{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    "pulumi-bin"
  ];
}
