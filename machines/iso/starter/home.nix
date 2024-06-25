{
  inputs,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  nix.registry.nixpkgs.flake = inputs.nixpkgs; # Make `nix shell` etc use pinned nixpkgs

  home = {
    username = "starter";
    homeDirectory = "/home/starter";
  };

  omakix = {
    enable = true;
    theme = "tokyo-night";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";
}
