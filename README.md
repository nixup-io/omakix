# An Omakase developer setup with Nix and Home Manager

Inspired by [DHH](https://dhh.dk/)'s [Omakub - "An Omakase Developer Setup for Ubuntu 24.04"](https://omakub.org/)

## Installation

...

## Usage

...

## Known limitations
* Depends on [Unfree Software](https://wiki.nixos.org/wiki/Unfree_Software) (`nixpkgs.config.allowUnfree = true;`) for obvious reasons
* Gnome does not yet support accent colors (see [Draft merge request: Support accent color](https://gitlab.gnome.org/GNOME/gnome-shell/-/merge_requests/2715)). Ubuntu has its own implementation for Gnome accent colors. This project uses the [Custom Accent Colors Gnome extension](https://extensions.gnome.org/extension/5547/custom-accent-colors/) but the supported colors are not an _exact_ match to Ubuntu's Gnome accent colors as used in Omakub.
* This project uses [NixVim](https://github.com/nix-community/nixvim) instead of [LazyVim](https://www.lazyvim.org/)
* Nixpkgs does not seem to have the `sainnhe.everforest` and `qufiwefefwoyn.kanagawa` VS Code extensions. These themes may work if the extension is installed through the marketplace?
* NixVim does not seem to support `colorschemes.everforest`. Omakix uses `colorschemes.base16.colorscheme = "everforest"` instead. This may not be accurate.
