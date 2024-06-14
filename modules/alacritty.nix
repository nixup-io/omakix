{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omakix;
in {
  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        colors.primary = {
          background = "#1a1b26";
          foreground = "#a9b1d6";
        };
        colors.normal = {
          black = "#32344a";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#ad8ee6";
          cyan = "#449dab";
          white = "#787c99";
        };
        colors.bright = {
          black = "#444b6a";
          red = "#ff7a93";
          green = "#b9f27c";
          yellow = "#ff9e64";
          blue = "#7da6ff";
          magenta = "#bb9af7";
          cyan = "#0db9d7";
          white = "#acb0d0";
        };
        colors.selection = {
          background = "#7aa2f7";
        };
        font = {
          size =
            if cfg.doubleScale
            then 7
            else 14;
          normal = {
            family = "CaskaydiaMono Nerd Font";
            style = "Regular";
          };
          bold = {
            family = "CaskaydiaMono Nerd Font";
            style = "Bold";
          };
          italic = {
            family = "CaskaydiaMono Nerd Font";
            style = "Italic";
          };
        };
        env.TERM = "xterm-256color";
        shell = {
          program = "${pkgs.zellij}/bin/zellij";
        };
        window = {
          padding.x = 16;
          padding.y = 14;
          decorations = "none";
          opacity = 0.97;
        };
        keyboard = {
          bindings = [
            {
              key = "F11";
              action = "ToggleFullscreen";
            }
          ];
        };
      };
    };
  };
}
