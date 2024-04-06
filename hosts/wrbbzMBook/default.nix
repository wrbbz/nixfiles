{ system, pkgs, ... }: {
  inherit pkgs system;

  my-config = {
    alacritty.enable = true;
    brew.enable = true;
    git.enable = true;
    nvim.enable = true;
    zsh.enable = true;
  };
}
