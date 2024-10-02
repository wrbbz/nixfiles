{ system, pkgs, ... }: {
  inherit pkgs system;

  my-config = {
    alacritty.enable = true;
    brew.enable = true;
    cli.enable = true;
    dev.enable = true;
    git.enable = true;
    kubernetes.enable = true;
    nvim.enable = true;
    pass = {
      enable = true;
      isDarwin = true;
    };
    starship.enable = true;
    zsh.enable = true;
  };
}
