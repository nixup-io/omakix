{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omakix;
in {
  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      settings = {
        theme = "tokyo-night";
        default_layout = "compact";
        themes = {
          tokyo-night = {
            fg = [169 177 214];
            bg = [26 27 38];
            black = [56 62 90];
            red = [249 51 87];
            green = [158 206 106];
            yellow = [224 175 104];
            blue = [122 162 247];
            magenta = [187 154 247];
            cyan = [42 195 222];
            white = [192 202 245];
            orange = [255 158 100];
          };
          gruvbox = {
            fg = "#d5c4a1";
            bg = "#282828";
            black = "#3c3836";
            red = "#cc241d";
            green = "#98971a";
            yellow = "#d79921";
            blue = "#3c8588";
            magenta = "#b16286";
            cyan = "#689d6a";
            white = "#fbf1c7";
            orange = "#d65d0e";
          };
        };
      };
    };
  };
}
