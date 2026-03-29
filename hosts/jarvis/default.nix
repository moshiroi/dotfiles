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
    ../../modules/nixos/gaming.nix
    ../../users/mohamedshire.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Compressed swap in RAM
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  boot.kernel.sysctl."vm.swappiness" = 180;

  networking.hostName = "jarvis";

  # Additional packages for desktop
  users.users.mohamedshire.packages = with pkgs; [ kdePackages.kate ];

  system.stateVersion = "25.05";
}
