{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omakix;
in {
  config = lib.mkIf cfg.enable {
    programs.bash = {
      enable = true;
      historyControl = ["ignoredups" "ignorespace"];
      historySize = 32768;
      historyFileSize = 32768;
      shellAliases = {
        # File system
        ls = "eza -lh --group-directories-first";
        lsa = "ls -a";
        lt = "eza --tree --level=2 --long --icons --git";
        lta = "lt -a";
        ff = "fzf --preview 'batcat --style=numbers --color=always {}'";

        # Directories
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";

        # Tools
        n = "nvim";
        g = "git";
        d = "docker";
        r = "rails";
        bat = "batcat";

        # Git
        gcm = "git commit -m";
        gcam = "git commit -a -m";
        gcad = "git commit -a --amend";

        # Compression
        decompress = "tar -xzf";
      };

      initExtra = ''
        compress() { tar -czf "''${1%/}.tar.gz" "''${1%/}"; }
        force_color_prompt=yes
        color_prompt=yes

        PS1=$'\uf0a9 '
        PS1="\[\e]0;\w\a\]$PS1"
      '';
    };
  };
}
