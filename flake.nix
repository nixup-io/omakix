{
  description = "An Omakase developer setup with Nix";

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
    nixpkgs,
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
    nixosConfigurations = {
      installer = nixpkgs.lib.nixosSystem {
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
          ./machines/installer/configuration.nix
        ];
        specialArgs = {inherit inputs;};
      };
    };

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

      installer-demo = pkgs.writeShellScript "installer-demo" ''
        set -euo pipefail
        disk=root.img
        if [ ! -f "$disk" ]; then
          echo "Creating harddisk image root.img"
          ${pkgs.qemu}/bin/qemu-img create -f qcow2 "$disk" 80G
        fi
        ${pkgs.qemu}/bin/qemu-system-x86_64 \
          -cpu host \
          -enable-kvm \
          -m 8G \
          -vga virtio \
          -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
          -cdrom ${self.packages.${system}.installer-iso}/iso/*.iso \
          -hda "$disk"
      '';

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

      installer-iso = inputs.self.nixosConfigurations.installer.config.system.build.isoImage;
    });

    apps = forAllSystems (system: {
      default = self.apps.${system}.demo;
      demo = {
        type = "app";
        program = "${self.packages.${system}.gui-vm}/bin/run-omakix-demo-vm";
      };
      installer-demo = {
        type = "app";
        program = "${self.packages.${system}.installer-demo}";
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
