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
    console.keyMap = "dvorak";

    virtualisation.qemu.options = [
      "-cpu host"
      "-enable-kvm"
      "-bios ${pkgs.OVMF.fd}/FV/OVMF.fd"
    ];

    networking.hostName = "omakix-console-vm";
    nixpkgs.config.allowUnfree = true;

    services.getty.autologinUser = "fake";

    security.sudo.wheelNeedsPassword = false;
    users.users.fake = {
      createHome = true;
      isNormalUser = true;
      extraGroups = ["networkmanager" "wheel"];
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

    system.stateVersion = "24.05";
  };
}
