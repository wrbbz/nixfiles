{ pkgs, ... }: {

  networking = {
    hostName = "wrbbzMBook";
  };

  environment.systemPackages = with pkgs; [
    pass
    zola
  ];
}
