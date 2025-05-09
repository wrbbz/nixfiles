# wrbbz's NixOS setup

This is my attempt to live with NixOS as a daily driver.
Be cautious that I'm still trying to figure Nix out and fit in.
There might be serious idiomatic & structural flaws.

| Machine       | System        | Status |
| --            | --            | --     |
| Desktop       | NixOS         | Done   |
| Laptop        | MacOS         | WIP    |

## Roadmap

- [ ] Make repo usable by multiple machines (see [Wimpy's repo](https://github.com/wimpysworld/nix-config))
- [ ] Adopt encryption or a way to store secrets separately (see [agenix](https://github.com/ryantm/agenix))
- [ ] Document the way(s) this repo is used

## Updating

Using Flake means that `nixpkgs` are no longer controlled by `nix-channel` of NixOS.
Instead, `nixpkgs` are locked to flake input.
To update the system one needs to update the input:

```sh
nix flake update --commit-lock-file
```

Next step is checking, what exactly was updated:

```sh
doas nixos-rebuild build --flake '/etc/nixos#' && nvd diff /run/current-system resu
```

The final step is to use new system/ switch to it:

```sh
doas nixos-rebuild switch --flake '/etc/nixos#'
```

### Updating nix-env packages

Before deciding if a given package is going to stick with my system I prefer to use it without adding it to my config.
So I add in to the nix-env.
These packages are not updated with the rest of the system through flake lock mechanism.
Instead, they are using nix channel configured for the root user (`nixos-unstable`).

First one needs to update a channel, info about available package:

```bash
sudo nix-channel --update
```

Then update packages themselves:

```bash
nix-env -u '*'
```

___
[original repository](https://gitlab.com/wrbbz/nixfiles)
