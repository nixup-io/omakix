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
    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = ["nix-command" "flakes"];

    virtualisation = {
      memorySize = 8192;
      qemu.options = [
        "-enable-kvm"
        "-vga virtio"
      ];
    };

    boot = {
      consoleLogLevel = 0;
      kernelParams = ["quiet"];
      initrd.verbose = false;
      plymouth = {
        enable = true;
        theme = "breeze";
      };
    };

    networking.hostName = "omakix-demo";
    i18n.inputMethod.enabled = "ibus";

    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      autoRepeatDelay = 200;
      autoRepeatInterval = 25;
    };

    services.displayManager.autoLogin = {
      enable = true;
      user = "demo";
    };

    services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];

    environment.gnome.excludePackages =
      (with pkgs; [
        gnome-tour
      ])
      ++ (with pkgs.gnome; [
        epiphany # web browser
      ]);

    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    security.sudo.wheelNeedsPassword = false;
    users.users.demo = {
      createHome = true;
      isNormalUser = true;
      extraGroups = ["networkmanager" "wheel" "docker"];
      initialPassword = "demo";
    };

    home-manager.users.demo = {
      home.stateVersion = "24.05";
      imports = [omakix-module];
      omakix = {
        enable = true;
        theme = "tokyo-night";
        font = "fira-mono";
        browser = "chromium";
      };
    };

    system.stateVersion = "24.05";
  };
}
