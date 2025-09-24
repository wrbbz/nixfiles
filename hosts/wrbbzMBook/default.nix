{ system, pkgs, ... }: {
  inherit pkgs system;

  my-config = {
    aerospace.enable = true;
    alacritty.enable = true;
    brew.enable = true;
    cli.enable = true;
    dev.enable = true;
    git = {
      enable = true;
      signing = {
        enable = true;
        personal = "0x8B5C43DC91052999";
        spbpu = "0xA6F136267FC4B239";
        work = "0x192BF2433F457001";
      };
    };
    kanata.enable = true;
    kubernetes.enable = true;
    mkalias.enable = true;
    nvim.enable = true;
    pass.enable = true;
    # slack.enable = true;
    starship.enable = true;
    telepresence.enable = true;
    zsh.enable = true;
  };
}
