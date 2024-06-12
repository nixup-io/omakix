{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omakix;
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # ia-fonts (Not in nixpkgs, see https://github.com/iaolo/iA-Fonts)
      _1password-gui
      apacheHttpd
      docker-buildx
      docker-compose
      fira-code
      gh
      gnome.gnome-tweaks
      gnomeExtensions.blur-my-shell
      gnomeExtensions.custom-accent-colors
      gnomeExtensions.just-perfection
      gnomeExtensions.space-bar
      gnomeExtensions.tactile
      gnomeExtensions.user-themes
      google-chrome
      lazydocker
      libffi
      libyaml
      localsend
      mysql84
      nerdfonts
      openssl
      pinta
      plocate
      signal-desktop
      source-code-pro
      spotify
      typora
      ulauncher
      vlc
      whatsapp-for-linux
      xournalpp
      yaru-theme
      zlib
      zoom-us
    ];

    programs.eza = {
      enable = true;
      icons = true;
    };
    programs.bat.enable = true;
    programs.btop.enable = true;
    programs.fzf.enable = true;
    programs.lazygit.enable = true;
    programs.ripgrep.enable = true;
    programs.zoxide.enable = true;
  };
}
