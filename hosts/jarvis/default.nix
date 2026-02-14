{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/virtualisation.nix
    ../../modules/nixos/obs.nix
    ../../users/mohamedshire.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "jarvis";

  # Additional packages for desktop
  users.users.mohamedshire.packages = with pkgs; [ kdePackages.kate ];

  system.stateVersion = "25.05";
}
