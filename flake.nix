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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    textfox.url = "github:adriankarlen/textfox";
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.url = "github:NixOS/nixpkgs?rev=a84b0a7c509bdbaafbe6fe6e947bdaa98acafb99";
    };
    sidra.url = "github:wimpysworld/sidra";

    nixflix = {
      url = "github:kiriwalawren/nixflix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      nixos-hardware,
      nix-homebrew,
      homebrew-bundle,
      homebrew-core,
      homebrew-cask,
      mac-app-util,
      textfox,
      sops-nix,
      sidra,
      nixflix,
      deploy-rs,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;

      mkSystem =
        {
          hostName,
          system,
          isDarwin ? false,
        }:
        (
          (
            {
              my-config ? { },
              zfs-root ? null,
              pkgs,
              system,
              ...
            }:
            let
              builder = if isDarwin then nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;

              hmModule =
                if isDarwin then
                  home-manager.darwinModules.home-manager
                else
                  home-manager.nixosModules.home-manager;

              pkgs = import nixpkgs {
                inherit system;
                config = {
                  permittedInsecurePackages = [
                    "electron-36.9.5"
                  ];
                };
              };

              entryModule =
                { lib, ... }:
                {
                  inherit my-config;

                  # Conditionally include zfs-root only on Linux
                }
                // (if isDarwin then { } else { inherit zfs-root; })
                // {

                  system.configurationRevision =
                    if (self ? rev) then self.rev else throw "refuse to build: git tree is dirty";

                  system.stateVersion = if isDarwin then 6 else "25.11";

                  imports = lib.optionals (!isDarwin) [
                    "${nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
                  ];
                };

              hostSpecific =
                if builtins.pathExists ./hosts/${hostName}/configuration.nix then
                  import ./hosts/${hostName}/configuration.nix (
                    if isDarwin then { inherit pkgs; } else { inherit pkgs nixos-hardware; }
                  )
                else
                  { };

              sharedConfig = import (if isDarwin then ./darwin.nix else ./configuration.nix) { inherit pkgs; };

              modules =
                (lib.optionals isDarwin [ mac-app-util.darwinModules.default ])
                ++ (lib.optionals (!isDarwin) [
                  sops-nix.nixosModules.sops
                  nixflix.nixosModules.default
                ])
                ++ [
                  ./modules
                  (if isDarwin then ./modules/darwin.nix else ./modules/linux.nix)

                  hostSpecific

                  (entryModule { inherit lib; })

                  # Home Manager (unified)
                  hmModule
                  {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.extraSpecialArgs = { inherit inputs; };
                    home-manager.sharedModules =
                      lib.optionals isDarwin [ mac-app-util.homeManagerModules.default ]
                      ++ [ sops-nix.homeManagerModules.sops ];
                  }

                  # Shared config per-OS
                  sharedConfig
                ]
                # Darwin-only Homebrew config, placed after shared config.
                ++ (lib.optionals isDarwin [
                  nix-homebrew.darwinModules.nix-homebrew
                  {
                    nix-homebrew = {
                      user = "wrbbz";
                      enable = true;
                      taps = {
                        "homebrew/homebrew-core" = homebrew-core;
                        "homebrew/homebrew-cask" = homebrew-cask;
                        "homebrew/homebrew-bundle" = homebrew-bundle;
                      };
                      mutableTaps = false;
                      autoMigrate = true;
                    };
                  }
                ]);
            in
            builder {
              inherit system;
              specialArgs = { inherit inputs isDarwin; };
              modules = modules;
            }
          )
          (
            import ./hosts/${hostName} {
              inherit system;
              pkgs = nixpkgs.legacyPackages.${system};
            }
          )
        );
    in
    {
      nixosConfigurations = {
        wrbbzCool = mkSystem {
          hostName = "wrbbzCool";
          system = "x86_64-linux";
        };
        wrbbzGM = mkSystem {
          hostName = "wrbbzGM";
          system = "x86_64-linux";
        };
        wrbbzLian = mkSystem {
          hostName = "wrbbzLian";
          system = "x86_64-linux";
        };
      };

      darwinConfigurations = {
        wrbbzMBook = mkSystem {
          hostName = "wrbbzMBook";
          system = "aarch64-darwin";
          isDarwin = true;
        };
      };

      deploy = {
        sshUser = "root";
        user = "root";
        # targets are x86_64-linux; build on the target instead of the Mac
        remoteBuild = true;
        sshOpts = [
          "-i"
          "~/.ssh/nix-deploy"
        ];
        nodes = lib.genAttrs [ "wrbbzCool" "wrbbzGM" "wrbbzLian" ] (hostName: {
          # resolved via ~/.ssh/config; override with `deploy --hostname <ip>` if needed
          hostname = hostName;
          profiles.system.path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${hostName};
        });
      };

      # only x86_64-linux: the checks depend on the target system closures,
      # which can't be built on darwin
      checks.x86_64-linux = deploy-rs.lib.x86_64-linux.deployChecks self.deploy;
    };
}
