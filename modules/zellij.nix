{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omakix;
in {
  config = lib.mkIf cfg.enable {
    xdg.configFile."zellij/themes" = {
      recursive = true;
      source = ./assets/themes/zellij;
    };

    programs.zellij = {
      enable = true;
      settings = {
        theme = cfg.theme;
        default_layout = "compact";
      };
    };
  };
}
