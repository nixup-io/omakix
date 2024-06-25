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

      # Warn user of imminent doom
      ${pkgs.gum}/bin/gum confirm --default=false \
      "🔥 🔥 🔥 WARNING!!!! This will ERASE ALL DATA on this computer. Are you sure you want to continue?"

      # Prompt the user to select a destination disk from a list of viable candidates
      unmounted_disks=$(lsblk -J | ${pkgs.jq}/bin/jq -r '
        def has_mounted_children(dev): any(dev.children[]?; any(.mountpoints[]?; . != null));
        .blockdevices[]
        | select(.mountpoints[] == null and (has_mounted_children(.) | not))
        | .name
      ')
      if [ -z "$unmounted_disks" ]; then
        echo "No viable target installation disks found. Exiting."
        exit 1
      fi
      diskname=$(echo "$unmounted_disks" | ${pkgs.gum}/bin/gum choose --header "Choose an installation disk")
      echo -n $diskname > /tmp/diskname

      # Prompt the user to enter a name for the first user account created in the new system
      username=$(${pkgs.gum}/bin/gum input --header "Set a username for your account")
      if [ -z "$username" ]; then
        echo "Username cannot be empty."
        exit 1
      fi

      # Prompt the user to enter a password used for full disk encryption
      secret_key=$(${pkgs.gum}/bin/gum input --password --header "Set a password for full disk encryption")
      if [ -z "$secret_key" ]; then
        echo "Disk encryption password cannot be empty."
        exit 1
      else
        echo -n $secret_key > /tmp/secret.key
      fi

      # Prepare the destination disk with declarative configuration using
      # Disko (https://github.com/nix-community/disko)
      ${pkgs.gum}/bin/gum spin \
        --title "Preparing destination disk for installation..." -- \
        sudo nix --experimental-features "nix-command flakes" \
        run github:nix-community/disko -- \
        --mode disko \
        ${./starter/disks.nix}

      # Generate initial NixOS configuration
      ${pkgs.gum}/bin/gum spin \
        --title "Generating initial NixOS configuration..." -- \
        sudo nixos-generate-config --root /mnt

      # Replace some template variables in the configuration with information received from the user through
      # earlier prompts
      sed "s/{{OMAKIX_USERNAME}}/$username/g" ${./starter/flake.nix} \
        | sudo tee /mnt/etc/nixos/flake.nix > /dev/null
      sed -e "s/{{OMAKIX_USERNAME}}/$username/g" \
        -e "s/{{OMAKIX_DISKNAME}}/$diskname/g" \
        ${./starter/configuration.nix} \
        | sudo tee /mnt/etc/nixos/configuration.nix > /dev/null
      sed "s/{{OMAKIX_USERNAME}}/$username/g" ${./starter/home.nix} \
        | sudo tee /mnt/etc/nixos/home.nix > /dev/null

      # Perform the actual NixOS installation
      ${pkgs.gum}/bin/gum spin \
        --title "Installing NixOS. This can take a while..." -- \
        sudo nixos-install --no-root-password --impure --flake /mnt/etc/nixos#omakix

      # Installation finished successfully (hopefully). Ask user for confirmation to reboot
      ${pkgs.gum}/bin/gum confirm "Installation complete. Reboot now?" \
        && sudo reboot \
        || echo "Installation complete. Please reboot manually."
    '';
in {
  isoImage.isoName = lib.mkForce "omakix-installer.iso";

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

  networking.hostName = "omakix-installer";

  services.qemuGuest.enable = true;

  services.openssh.enable = lib.mkForce false;

  # Inhibit sleep, suspend, hibernate
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  environment.systemPackages = with pkgs; [
    git
    omakix-installer
  ];

  programs.bash.interactiveShellInit = ''
    omakix-installer
  '';
}
