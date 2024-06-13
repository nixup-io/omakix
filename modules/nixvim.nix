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

      colorschemes.tokyo-night.enable = true;
      plugins.lightline.enable = true;
    };
  };
}
