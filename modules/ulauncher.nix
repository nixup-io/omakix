{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.omakix;
in {
  config = lib.mkIf cfg.enable {
    # Ulauncher
    home.file.".config/autostart/ulauncher.desktop" = {
      text = ''
        [Desktop Entry]
        Name=Ulauncher
        Comment=Application launcher for Linux
        GenericName=Launcher
        Categories=GNOME;GTK;Utility;
        TryExec=${pkgs.ulauncher}/bin/ulauncher
        Exec=env GDK_BACKEND=x11 ${pkgs.ulauncher}/bin/ulauncher --hide-window --hide-window
        Icon=ulauncher
        Terminal=false
        Type=Application
        X-GNOME-Autostart-enabled=true
      '';
      force = true; # overwrite existing
    };
    home.file.".config/ulauncher/settings.json" = {
      text = ''
        {
          "clear-previous-query": true,
          "disable-desktop-filters": false,
          "grab-mouse-pointer": false,
          "hotkey-show-app": "null",
          "render-on-screen": "mouse-pointer-monitor",
          "show-indicator-icon": true,
          "show-recent-apps": "0",
          "terminal-command": "",
          "theme-name": "dark"
        }
      '';
      force = true;
    };
  };
}
