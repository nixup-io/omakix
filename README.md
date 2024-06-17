# An Omakase developer setup with Nix

[Nix](https://nixos.org/) port of [Omakub - "An Omakase Developer Setup for Ubuntu 24.04"](https://omakub.org/) by [DHH](https://dhh.dk/).

## Assumptions

- You're running [NixOS 24.05](https://nixos.org/download/) stable with Gnome (as [Omakub](https://omakub.org) is built around Gnome)
- You're using Home Manager as a NixOS module with or without flakes
- You have enabled unfree software (`nixpkgs.config.allowUnfree = true;`)

## Installation

### With flakes

1. Add Omakix as an input to your system configuration flake

```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
  home-manager = {
    url = "github:nix-community/home-manager/release-24.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  omakix = {
    url = "github:nixup-io/omakix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };
};
```

2. Add the necessary incantations to your nixosConfiguration

```nix
  outputs = {
    self,
    nixpkgs,
    home-manager,
    omakix,
  }: {
    nixosConfigurations = {
      your-nixos-hostname = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            # Ensure Home Manager uses unfree enabled nixpkgs
            home-manager.useGlobalPkgs = true;
            home-manager.sharedModules = [omakix.homeManagerModules.omakix];
            home-manager.users.YOUR_USERNAME = {pkgs, ...}: {
              omakix = {
                enable = true;
                theme = "catppuccin"; # Try "catppuccin", "everforest", "gruvbox", "kanagawa", "nord" or "rose-pine" instead
              };
              home.stateVersion = "24.05";
            };
          }
        ];
      };
    };
  };
```

3. Rebuild your system and reboot

Rebooting rather than switching into the new configuration for the first time will make sure everything is loaded properly.

```sh
sudo nixos-rebuild --flake . boot
sudo reboot
```

4. Switch themes

Change `omakix.theme` to another supported theme, e.g. `"catppuccin"`.

Switch to the new system configuration:

```sh
sudo nixos-rebuild --flake . switch
```

You may have to log out and back in again if you notice that the configuration was not applied everywhere.

5. Go do something productive

### Without flakes

1. Install Home Manager as a NixOS module

Add the Home Manager stable channel and update channels

```sh
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
```

Add the Omakix channel

```sh
sudo nix-channel --add https://github.com/nixup-io/omakix/archive/master.tar.gz omakix
```

Update channels

```sh
sudo nix-channel --update
```

Add Home Manager and Omakix to your system's `configuration.nix`

```nix
{ config, pkgs, ... }:

{
  imports = [
    ... # Other imports, probably hardware-configuration.nix
    <home-manager/nixos>
  ];

  ... # The rest of your system configuration

  # builtins.fetchGit for NixVim below needs git
  environment.systemPackages = with pkgs; [ git ];

  # Omakix depends on unfree packages
  nixpkgs.config.allowUnfree = true;

  # Ensure Home Manager uses unfree enabled nixpkgs
  home-manager.useGlobalPkgs = true;

  # Your Home Manager configuration
  home-manager.users.YOUR_USERNAME = { pkgs, ... }:
    let
      # Omakix depends on NixVim
      nixvim = import (builtins.fetchGit {
        url = "https://github.com/nix-community/nixvim?ref=nixos-24.05";
      });
    in {
      imports = [
        nixvim.homeManagerModules.nixvim
        <omakix/modules>
      ];

      omakix = {
        enable = true;
        theme = "tokyo-night"; # Try "catppuccin", "everforest", "gruvbox", "kanagawa", "nord" or "rose-pine" instead
      };

      home.stateVersion = "24.05";
    };
}
```

2. Rebuild your system and reboot

Rebooting rather than switching into the new configuration for the first time will make sure everything is loaded properly.

```sh
sudo nixos-rebuild boot
sudo reboot
```

3. Switch themes

Change `omakix.theme` to another supported theme, e.g. `"catppuccin"`.

Switch to the new system configuration:

```sh
sudo nixos-rebuild switch
```

You may have to log out and back in again if you notice that the configuration was not applied everywhere.

4. Go do something productive

## Known limitations

- Depends on [Unfree Software](https://wiki.nixos.org/wiki/Unfree_Software) (`nixpkgs.config.allowUnfree = true;`) for obvious reasons
- Gnome does not yet support accent colors (see [Draft merge request: Support accent color](https://gitlab.gnome.org/GNOME/gnome-shell/-/merge_requests/2715)). Ubuntu has its own implementation for Gnome accent colors. This project uses the [Custom Accent Colors Gnome extension](https://extensions.gnome.org/extension/5547/custom-accent-colors/) but the supported colors are not an _exact_ match to Ubuntu's Gnome accent colors as used in Omakub.
- This project uses [NixVim](https://github.com/nix-community/nixvim) instead of [LazyVim](https://www.lazyvim.org/)
- Nixpkgs does not seem to have the `sainnhe.everforest` and `qufiwefefwoyn.kanagawa` VS Code extensions. These themes may work if the extension is installed through the marketplace?
- NixVim does not seem to support `colorschemes.everforest`. Omakix uses `colorschemes.base16.colorscheme = "everforest"` instead. This may not be accurate.

## Acknowledgements

- Thanks to [DHH](https://dhh.dk/) for spelunking through no doubt countless rabbit holes to come up with [Omakub - "An Omakase Developer Setup for Ubuntu 24.04"](https://omakub.org/). And thanks for [Ruby On Rails](https://rubyonrails.org/), David. For 18 years Rails has given my programming career such a pleasant and efficient workflow that I can afford to waste countless hours on stuff like this.

- Thanks to snow at [VoidWarranties](https://we.voidwarranties.be/) for diving into Nix and testing omakix

- Thanks to [KDE Plasma Manager](https://github.com/pjones/plasma-manager) for inspiration on how to add modules to [Home Manager](https://github.com/nix-community/home-manager)

- [Nix](https://nixos.org/) is awesome
