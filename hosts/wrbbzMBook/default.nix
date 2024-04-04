{ system, pkgs, ... }: {
  inherit pkgs system;

  my-config = {
    alacritty.enable = true;
    git.enable = true;
    pass.enable = true;
    zsh.enable = true;
  };
}
