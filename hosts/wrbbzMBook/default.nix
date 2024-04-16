{ system, pkgs, ... }: {
  inherit pkgs system;

  options.networking = {
    computerName = "wrbbzMBook";
  };

  my-config = {
    alacritty.enable = true;
    brew.enable = true;
    git.enable = true;
    nvim.enable = true;
    starship.enable = true;
    zsh.enable = true;
  };
}
