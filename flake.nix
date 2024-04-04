{
  description = "wrbbz's personal NixOS setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nixos-hardware }:
    let
      mkHost = hostName: system:
        (({ my-config, zfs-root, pkgs, system, ... }:
          nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              # Module 0: zfs-root
              ./modules

              # Module 1: host-specific config, if exist
              (if (builtins.pathExists
                ./hosts/${hostName}/configuration.nix) then
                (import ./hosts/${hostName}/configuration.nix { inherit pkgs nixos-hardware; })
              else
                { })

              # Module 2: entry point
              (({ my-config, zfs-root, pkgs, lib, ... }: {
                inherit my-config zfs-root;
                system.configurationRevision = if (self ? rev) then
                  self.rev
                else
                  throw "refuse to build: git tree is dirty";
                system.stateVersion = "23.05";
                imports = [
                  "${nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
                  # "${nixpkgs}/nixos/modules/profiles/hardened.nix"
                  # "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
                ];
              }) {
                inherit my-config zfs-root pkgs;
                lib = nixpkgs.lib;
              })

              # Module 3: home-manager
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
              }

              # Module 4: config shared by all hosts
              (import ./configuration.nix { inherit pkgs; })
            ];
          })

        # configuration input
          (import ./hosts/${hostName} {
            system = system;
            pkgs = nixpkgs.legacyPackages.${system};
          }));

      mkDarwin = hostName: system:
         (({ my-config, pkgs, system, ... }:
            nix-darwin.lib.darwinSystem {
            inherit system;
            modules = [
                # Module 0: zfs-root
                ./modules/darwin.nix

                # Module 1: host-specific config, if exist
                (if (builtins.pathExists
                ./hosts/${hostName}/configuration.nix) then
                (import ./hosts/${hostName}/configuration.nix { inherit pkgs nixos-hardware; })
                else
                { })

                # Module 2: entry point
                (({ my-config, pkgs, lib, ... }: {
                inherit my-config;
                system.configurationRevision = if (self ? rev) then
                    self.rev
                else
                    throw "refuse to build: git tree is dirty";
                system.stateVersion = "23.05";
                imports = [
                    "${nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
                ];
                }) {
                inherit my-config pkgs;
                lib = nixpkgs.lib;
                })

                # Module 3: home-manager
                home-manager.nixosModules.home-manager
                {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                }

                # Module 4: config shared by all hosts
                # (import ./configuration.nix { inherit pkgs; })
            ];
            })
            (import ./hosts/${hostName} {
            system = system;
            pkgs = nixpkgs.legacyPackages.${system};
            }));
    in {
      nixosConfigurations = {
        wrbbzCool = mkHost "wrbbzCool" "x86_64-linux";
      };
      darwinConfigurations = {
        wrbbzMBook = mkDarwin "wrbbzMBook" "aarch64-darwin";
      };
    };
}
