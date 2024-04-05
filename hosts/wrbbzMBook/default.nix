{ system, pkgs, ... }: {
  inherit pkgs system;

  services.nix-daemon.enable = true;

  my-config = {
    git.enable = true;
  };
}
