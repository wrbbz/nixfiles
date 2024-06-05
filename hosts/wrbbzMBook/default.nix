{ system, pkgs, ... }: {
  inherit pkgs system;

  my-config = {
    alacritty.enable = true;
    brew.enable = true;
    git.enable = true;
    kubernetes.enable = true;
    nvim.enable = true;
    starship.enable = true;
    zsh.enable = true;
  };
}
