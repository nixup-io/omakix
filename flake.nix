{
  description = "An Omakase developer setup with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixvim,
    ...
  }: let
    # Systems that can run tests:
    supportedSystems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
    ];

    # Function to generate a set based on supported systems:
    forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

    # Attribute set of nixpkgs for each system:
    nixpkgsFor = forAllSystems (system:
      import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
  in {
    homeManagerModules.omakix = {...}: {
      imports = [
        nixvim.homeManagerModules.nixvim
        ./modules
      ];
    };

    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      default = self.packages.${system}.gui-vm;

      gui-vm =
        (inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (import test/gui-vm.nix {
              inherit pkgs;
              home-manager-module = inputs.home-manager.nixosModules.home-manager;
              omakix-module = self.homeManagerModules.omakix;
            })
          ];
        })
        .config
        .system
        .build
        .vm;
    });

    apps = forAllSystems (system: {
      default = self.apps.${system}.demo;
      demo = {
        type = "app";
        program = "${self.packages.${system}.gui-vm}/bin/run-omakix-demo-vm";
      };
    });

    checks = forAllSystems (system: {
      default = nixpkgsFor.${system}.callPackage ./test/basic.nix {
        home-manager-module = inputs.home-manager.nixosModules.home-manager;
        omakix-module = self.homeManagerModules.omakix;
      };
    });

    formatter = forAllSystems (system: nixpkgsFor.${system}.alejandra);
  };
}
