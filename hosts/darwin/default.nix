{ pkgs, username, ... }:
{
  imports = [
    ../../modules/darwin/linux-builder.nix
  ];

  ids.gids.nixbld = 350;
  nixpkgs.config.allowUnfree = true;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.nushell;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFUJBV5UfedJQE8qPmosVK7s1xbK+VgrhFC7qolLvPo2 mohamedshire@nixos"
    ];
  };

  system.stateVersion = 4;
  system.primaryUser = username;
}
