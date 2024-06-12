{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omakix;
in {
  config = lib.mkIf cfg.enable {
    programs.mise = {
      enable = true;
      globalConfig = {
        tools = {
          node = "lts";
          ruby = ["3.3"];
        };
      };
    };
  };
}
