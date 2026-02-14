{ config, lib, pkgs, nixos-wsl, ... }:

{
  imports = [
    # include NixOS-WSL modules
    nixos-wsl.nixosModules.default
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/networking.nix
    ./nvidia-wsl.nix
  ];

  wsl = {
    enable = true;
    defaultUser = "nixos";
    # Enable integration with Docker Desktop (needs to be installed)
    docker-desktop.enable = false;

    extraBin = with pkgs; [
      # Binaries for Docker Desktop wsl-distro-proxy
      { src = "${coreutils}/bin/mkdir"; }
      { src = "${coreutils}/bin/cat"; }
      { src = "${coreutils}/bin/whoami"; }
      { src = "${coreutils}/bin/ls"; }
      { src = "${busybox}/bin/addgroup"; }
      { src = "${su}/bin/groupadd"; }
      { src = "${su}/bin/usermod"; }
    ];

    wslConf.network.networkingMode = "mirrored";
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  ## patch the script
  systemd.services.docker-desktop-proxy.script = lib.mkForce ''${config.wsl.wslConf.automount.root}/wsl/docker-desktop/docker-desktop-user-distro proxy --docker-desktop-root ${config.wsl.wslConf.automount.root}/wsl/docker-desktop "C:\Program Files\Docker\Docker\resources"'';

  programs.nix-ld.enable = true;

  services.dbus.enable = true;
  users.defaultUserShell = pkgs.nushell;
  fonts.packages = with pkgs; [ nerd-fonts.fira-code ];

  users.users.nixos = {
    isNormalUser = true;
  };

  system.stateVersion = "24.05";
}
