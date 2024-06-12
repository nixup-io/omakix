{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omakix;
in {
  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      aliases = {
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
      };
      extraConfig = {
        pull.rebase = true;
      };
    };
  };
}
