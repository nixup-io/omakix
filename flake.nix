{
  description = "An Omakase developer setup with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixos-generators,
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
      imports = [./modules];
    };

    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      default = self.packages.${system}.demo;

      demo =
        (inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (import test/demo.nix {
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

      iso = nixos-generators.nixosGenerate {
        inherit system;
        specialArgs = {
          inherit pkgs;
          diskSize = 20 * 1024;
        };
        modules = [
          # Pin nixpkgs to the flake input, so that the packages installed
          # come from the flake inputs.nixpkgs.url.
          ({...}: {nix.registry.nixpkgs.flake = inputs.nixpkgs;})
          # Apply the rest of the config.
          (import test/demo.nix {
            inherit pkgs;
            home-manager-module = inputs.home-manager.nixosModules.home-manager;
            omakix-module = self.homeManagerModules.omakix;
          })
        ];
        format = "iso";
      };
    });

    apps = forAllSystems (system: {
      default = self.apps.${system}.demo;
      demo = {
        type = "app";
        program = "${self.packages.${system}.demo}/bin/run-omakix-demo-vm";
      };
    });

    checks = forAllSystems (system: {
      default = nixpkgsFor.${system}.callPackage ./test/basic.nix {
        home-manager-module = inputs.home-manager.nixosModules.home-manager;
        omakix-module = self.homeManagerModules.omakix;
      };
    });

    formatter = forAllSystems (system: nixpkgsFor.${system}.alejandra);

    devShells = forAllSystems (system: {
      default = nixpkgsFor.${system}.mkShell {
        buildInputs = with nixpkgsFor.${system}; [
          # FIXME(m): Check if any packages needed otherwise remove this devshell
          hello
        ];
      };
    });
  };
}
