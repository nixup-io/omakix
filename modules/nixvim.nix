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
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      colorschemes.tokyonight.enable = true;
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
