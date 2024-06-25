{
  pkgs,
  lib,
  ...
}: let
    omakix-installer = pkgs.writeShellScriptBin "omakix-installer" ''
      #!/usr/bin/env bash
      set -euo pipefail

      if [ "$(id -u)" -eq 0 ]; then
        echo "ERROR! $(basename "$0") should be run as a regular user"
        exit 1
      fi

      gum confirm  --default=false \
      "🔥 🔥 🔥 WARNING!!!! This will ERASE ALL DATA on this computer. Are you sure you want to continue?"

      sudo nix --experimental-features "nix-command flakes" \
      run github:nix-community/disko -- \
      --mode disko \
      ${./starter/disks.nix}

      sudo nixos-generate-config --root /mnt
      sudo cp ${./starter/flake.nix} /mnt/etc/nixos/flake.nix
      sudo cp ${./starter/configuration.nix} /mnt/etc/nixos/configuration.nix
      sudo cp ${./starter/home.nix} /mnt/etc/nixos/home.nix

      sudo nixos-install --flake /mnt/etc/nixos#omakix
    '';
in {
  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    config.allowUnfree = true;
  };

  nix = {
    settings.experimental-features = ["nix-command" "flakes"];
    extraOptions = "experimental-features = nix-command flakes";
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = lib.mkForce ["btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs"];
  };

  networking = {
    hostName = "omakix-installer";
  };

  services = {
    qemuGuest.enable = true;
  };

  # Inhibit sleep, suspend, hibernate
  systemd = {
    services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };

  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILes7WTtBxDp1ILq+9iF1v2mmiQ0yFPprMREPUO240me m@Tatooine.local"
  ];

  environment.systemPackages = with pkgs; [
    git
    gum
    omakix-installer
  ];

  programs.bash.interactiveShellInit = ''
    omakix-installer
  '';
}
