{ system, pkgs, ... }: {
  inherit pkgs system;

  my-config = {
    git.enable = true;
    nvim.enable = true;
    zsh.enable = true;
  };
}
