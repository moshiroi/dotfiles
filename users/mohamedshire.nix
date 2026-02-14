{ pkgs, ... }:
{
  users.users.mohamedshire = {
    isNormalUser = true;
    description = "mohamedshire";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.nushell;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBdBDe4ecx1G0o+n9Zu49TcGyZkT+LhONyKToDHvhjqB"  # personal macbook
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIImX1m8CywztA1TkEBd2xSCgJnyzjKrgmdjhlTrWGicL"  # macbook pro
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFUJBV5UfedJQE8qPmosVK7s1xbK+VgrhFC7qolLvPo2"  # nixos wsl
    ];
  };
}
