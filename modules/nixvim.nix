{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omakix;
  colorScheme =
    if cfg.theme == "tokyo-night"
    then "tokyonight"
    else cfg.theme;
in {
  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      colorschemes =
        if colorScheme == "everforest"
        then {
          base16 = {
            enable = true;
            colorscheme = "everforest";
          };
        }
        else {
          "${colorScheme}" = lib.mkMerge [
            {enable = true;}
            (lib.mkIf (cfg.theme == "rose-pine") {settings.variant = "dawn";})
          ];
        };
      globals.mapleader = " ";
      opts = {
        number = true;
        shiftwidth = 2;
        cursorline = true;
      };
      plugins = {
        lualine.enable = true;
        neo-tree.enable = true;
        telescope.enable = true;
        treesitter.enable = true;
        noice.enable = true;
        transparent.enable = true;
        lsp = {
          enable = true;
          servers = {
            ruby-lsp.enable = true;
          };
        };
      };
    };
  };
}
