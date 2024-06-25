# An Omakase developer setup with Nix

[Nix](https://nixos.org/) port of [Omakub - "An Omakase Developer Setup for Ubuntu 24.04"](https://omakub.org/) by [DHH](https://dhh.dk/).

When DHH released Omakub, I was intrigued by the idea and because of my desire to level up my Nix skills, I decided to go Omakase on the Omakase and add my own opinionated Nix sauce to the mix.

![Yo dawg I heard you like Omakase](https://i.imgflip.com/8uxrv9.jpg)

## Assumptions

- You're running [NixOS 24.05](https://nixos.org/download/) stable with Gnome (as [Omakub](https://omakub.org) is built around Gnome). If you're not running NixOS yet, download the batteries included [Omakix installation ISO](https://github.com/nixup-io/omakix/releases/download/v1.0.0/omakix-v1.0.0-installer.iso)
- You're using Home Manager as a NixOS module with or without flakes
- You have enabled unfree software (`nixpkgs.config.allowUnfree = true;`)

## Installation

### Omakase style

1. Download the latest [Omakix installer ISO](https://github.com/nixup-io/omakix/releases/download/v1.0.0/omakix-v1.0.0-installer.iso)

2. Flash it to a suitable USB drive

3. Boot it, install it, enjoy it

4. Alternatively and arguably the more sensible thing to do with ISO's from random strangers on the Internet: boot it in a virtual machine

**Note:** The installer ISO assumes you're booting with UEFI and will partition the destination disk with GPT and enable full disk encryption (LUKS).

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

## Things you can do with this flake

This assumes you're running NixOS or another Linux distribution and have the Nix package manager installed.

Run a demo VM with Omakix enabled

```sh
nix run github:nixup-io/omakix
```

Generate your very own ISO installation image

```sh
nix build github:nixup-io/omakix#installer-iso
# The ISO image will be in result/iso/

# Or after customizing the nix configuration in machines/installer
nix build .#installer-iso
```

Run the, arguably limited, test suite

```sh
nix flake check github:nixup-io/omakix
```

## Known limitations

- Depends on [Unfree Software](https://wiki.nixos.org/wiki/Unfree_Software) (`nixpkgs.config.allowUnfree = true;`) for obvious reasons
- Gnome does not yet support accent colors (see [Draft merge request: Support accent color](https://gitlab.gnome.org/GNOME/gnome-shell/-/merge_requests/2715)). Ubuntu has its own implementation for Gnome accent colors. This project uses the [Custom Accent Colors Gnome extension](https://extensions.gnome.org/extension/5547/custom-accent-colors/) but the supported colors are not an _exact_ match to Ubuntu's Gnome accent colors as used in Omakub.
- This project uses [NixVim](https://github.com/nix-community/nixvim) instead of [LazyVim](https://www.lazyvim.org/)
- Nixpkgs does not seem to have the `sainnhe.everforest` and `qufiwefefwoyn.kanagawa` VS Code extensions. These themes may work if the extension is installed through the marketplace?
- NixVim does not seem to support `colorschemes.everforest`. Omakix uses `colorschemes.base16.colorscheme = "everforest"` instead. This may not be accurate.

## Contribution

"Wow this is absolutely awesome, I cannot hold my enthusiasm to contribute to this."

Well fear not fellow traveler of Cyberspace because you can:

- It's possible this doesn't even work on the first try. If that's the case, [open an issue](https://github.com/nixup-io/omakix/issues/new). Better yet, fix the problem and [open a PR](https://github.com/nixup-io/omakix/pulls).

- If you are a Nix expert and cringe at my absolutely awful, totally not copied from elsewhere Nix code, please [open PRs](https://github.com/nixup-io/omakix/pulls) with suggestions on how to improve things. I'm not necessarily looking for more abstractions, but welcome improvements to the way it's currently done. Most of this was "inspired" by [KDE Plasma Manager](https://github.com/pjones/plasma-manager) and [NixOS Auto Installer](https://github.com/tfc/nixos-auto-installer). See [Nix related issues](https://github.com/nixup-io/omakix/labels/nix).

- I need people to do exhaustive feature comparison between Omakub and this project. If you spot something that isn't exactly like it is set up in Omakub, open an issue for it. Keep in mind that the fact that Omakub is based on Ubuntu, there may be some differences that are harder to overcome. Although that would of course never be attributed to a problem with NixOS. Check out [known things that need porting over](https://github.com/nixup-io/omakix/labels/omakub-port).

- We need an equivalent thing to "I use Arch, by the way" for Nix(OS) to use at cocktail parties. Suggestions welcome!

## Acknowledgements

- Thanks to [DHH](https://dhh.dk/) for spelunking through no doubt countless rabbit holes to come up with [Omakub - "An Omakase Developer Setup for Ubuntu 24.04"](https://omakub.org/). And thanks for [Ruby On Rails](https://rubyonrails.org/), David. For 18 years Rails has given my programming career such a pleasant and efficient workflow that I can afford to waste countless hours on stuff like this.

- Thanks to [Typecraft](https://www.youtube.com/watch?v=g2vcIRavtqY) for his videos which have been instrumental to DHH for making Omakub. I enjoyed the video coverage on Omakub and I like your style, man. I am a fellow [Ruby on Rails](https://rubyonrails.org/) veteran who's looking at 18 years and counting now). Though admittedly I don't use Arch (btw).

- Thanks to snow at [VoidWarranties](https://we.voidwarranties.be/) for diving into Nix and testing Omakix out!

- Thanks to [KDE Plasma Manager](https://github.com/pjones/plasma-manager) for inspiration on how to add modules to [Home Manager](https://github.com/nix-community/home-manager) and thanks to [NixOS Auto Installer](https://github.com/tfc/nixos-auto-installer) for ideas on how to build a quasi unattended NixOS installer.

- [Nix](https://nixos.org/) is awesome.

## Contact

- You can reach me via [good old e-mail](mailto:shmitty@protonmail.com) for a serious and more meaningful conversation if you're into that kind of thing

- You can also [find me on X](https://x.com/michaelshmitty) or in the [Fediverse over at Mastodon](https://social.hacktheplanet.be/@neo)

- Check out my website over at https://michaelsmith.be for more outdated information prior to hiring me
