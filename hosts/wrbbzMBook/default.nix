{ system, pkgs, ... }: {
  inherit pkgs system;

  my-config = {
    brew.enable = true;
    git.enable = true;
    nvim.enable = true;
    zsh.enable = true;
  };
}
