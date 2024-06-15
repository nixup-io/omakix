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
    ./nixvim.nix
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
      type = types.enum [
        "catppuccin"
        "everforest"
        "gruvbox"
        "kanagawa"
        "nord"
        "rose-pine"
        "tokyo-night"
      ];
      default = "tokyo-night";
      description = "Choose your theme.";
      example = "catppuccin";
    };

    font = lib.mkOption {
      type = types.enum [
        "cascadia-mono"
        "fira-mono"
        "jetbrains-mono"
        "meslo"
      ];
      default = "cascadia-mono";
      description = "Choose your programming font.";
      example = "fira-mono";
    };

    doubleScale = lib.mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable to assume a 200% display scale for an arguably better look on the Framework 13 laptop display.
      '';
      example = true;
    };
  };
}
