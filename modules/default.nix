{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.omakix;
in {
  imports = [
    ./alacritty.nix
    ./git.nix
    ./gnome.nix
    ./mise.nix
    ./neovim.nix
    ./other-programs.nix
    ./readline.nix
    ./shell.nix
    ./typora.nix
    ./ulauncher.nix
    ./vscode.nix
    ./zellij.nix
  ];

  options.omakix = {
    enable = mkEnableOption ''
      Enable an Omakase developer setup with Home Manager.
    '';

    theme = lib.mkOption {
      type = types.str;
      description = "Choose your theme.";
      example = "tokyo-night";
    };

    font = lib.mkOption {
      type = types.str;
      description = "Choose your programming font.";
      example = "CaskaydiaMono Nerd Font";
    };
  };
}
