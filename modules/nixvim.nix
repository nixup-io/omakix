{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omakix;
in {
  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;

      colorschemes.tokyonight.enable = true;
      plugins.transparent.enable = true;
    };
  };
}
