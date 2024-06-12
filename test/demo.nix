{
  pkgs,
  home-manager-module,
  omakix-module,
}: {modulesPath, ...}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/virtualisation/qemu-vm.nix")
    home-manager-module
    {home-manager.useGlobalPkgs = true;}
  ];

  config = {
    networking.hostName = "omakix-demo";

    nixpkgs.config.allowUnfree = true;

    i18n.inputMethod.enabled = "ibus";

    services.xserver = {
      enable = true;
      videoDrivers = ["qxl"];
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    services.displayManager.autoLogin = {
      enable = true;
      user = "fake";
    };

    programs.dconf.enable = true;

    services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];

    environment.gnome.excludePackages =
      (with pkgs; [
        gnome-tour
      ])
      ++ (with pkgs.gnome; [
        epiphany # web browser
      ]);

    nixpkgs.overlays = [
      (final: prev: {
        gnome = prev.gnome.overrideScope (
          gnomeFinal: gnomePrev: {
            mutter = gnomePrev.mutter.overrideAttrs (old: {
              src = pkgs.fetchgit {
                url = "https://gitlab.gnome.org/vanvugt/mutter.git";
                rev = "94f500589efe6b04aa478b3df8322eb81307d89f";
                sha256 = "sha256-fkPjB/5DPBX06t7yj0Rb3UEuu5b9mu3aS+jhH18+lpI=";
              };
            });
          }
        );
      })
    ];

    system.stateVersion = "24.05";

    users.users.fake = {
      createHome = true;
      isNormalUser = true;
      password = "password";
      group = "users";
    };

    home-manager.users.fake = {
      home.stateVersion = "24.05";
      imports = [omakix-module];
      omakix = {
        enable = true;
        theme = "tokyo-night";
        font = "CaskaydiaMono Nerd Font";
      };
    };
  };
}
