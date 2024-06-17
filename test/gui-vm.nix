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
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    virtualisation = {
      memorySize = 8192;
      qemu.options = [
        "-enable-kvm"
        "-vga virtio"
      ];
    };

    networking.hostName = "omakix-demo";
    nixpkgs.config.allowUnfree = true;
    i18n.inputMethod.enabled = "ibus";

    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      autoRepeatDelay = 200;
      autoRepeatInterval = 25;
      xkb = {
        layout = "us";
        variant = "dvorak";
      };
    };

    services.displayManager.autoLogin = {
      enable = true;
      user = "demo";
    };

    console.useXkbConfig = true;

    services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];

    environment.gnome.excludePackages =
      (with pkgs; [
        gnome-tour
      ])
      ++ (with pkgs.gnome; [
        epiphany # web browser
      ]);

    security.sudo.wheelNeedsPassword = false;
    users.users.demo = {
      createHome = true;
      isNormalUser = true;
      extraGroups = ["networkmanager" "wheel"];
      initialPassword = "demo";
    };

    home-manager.users.demo = {
      home.stateVersion = "24.05";
      imports = [omakix-module];
      omakix = {
        enable = true;
        theme = "catppuccin";
        font = "fira-mono";
      };
    };

    system.stateVersion = "24.05";
  };
}
