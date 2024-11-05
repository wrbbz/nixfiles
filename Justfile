propagate := if "{{ os }}" == "linux" { "doas" } else { "sudo" }
[private]
default:
  @just --list

# Updates flake and commits lock files
update:
  git stash
  git pull
  nix flake update --commit-lock-file
  git push
  git stash pop

# Updates flake only
update-dry:
  nix flake update

# Builds current revision of NixOs
[linux]
build:
  doas nixos-rebuild build --flake /etc/nixos && nvd diff /run/current-system result

# Builds current revision of nix-darwin
[macos]
build:
  nix run nix-darwin -- build --flake ~/repos/nixfiles && nvd diff /run/current-system result

# Switches to the built NixOs revision
[linux]
switch:
  doas nixos-rebuild switch --flake /etc/nixos

# Switches to the built nix-darwin revision
[macos]
switch:
  nix run nix-darwin -- switch --flake ~/repos/nixfiles

# Garbage collect all unused nix store entries
gc:
  # garbage collect all unused nix store entries(system-wide)
  {{ propagate }} nix-collect-garbage --delete-older-than 7d
  # garbage collect all unused nix store entries(for the user - home-manager)
  # https://github.com/NixOS/nix/issues/8508
  nix-collect-garbage --delete-older-than 7d
