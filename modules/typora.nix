{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omakix;
in {
  config = lib.mkIf cfg.enable {
    xdg.configFile."Typora/themes" = {
      recursive = true;
      source = ./assets/typora-themes;
    };
  };
}
