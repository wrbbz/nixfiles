{ system, pkgs, ... }: {
  inherit pkgs system;

  my-config = {
    git.enable = true;
  };
}
