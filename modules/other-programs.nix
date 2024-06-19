{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omakix;
  ia-fonts = pkgs.callPackage ../packages/ia-fonts.nix {};
in {
  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      _1password-gui
      apacheHttpd
      docker-buildx
      docker-compose
      fastfetch
      fd
      fira-code
      gh
      gnome.gnome-tweaks
      gnomeExtensions.blur-my-shell
      gnomeExtensions.custom-accent-colors
      gnomeExtensions.just-perfection
      gnomeExtensions.space-bar
      gnomeExtensions.tactile
      gnomeExtensions.undecorate
      gnomeExtensions.user-themes
      google-chrome
      ia-fonts
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
