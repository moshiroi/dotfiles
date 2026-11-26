{ pkgs, username, ... }:
{
  imports = [
    ../../modules/darwin/linux-builder.nix
  ];

  ids.gids.nixbld = 350;
  nixpkgs.config.allowUnfree = true;

  # nix-darwin only applies `shell` to users it knows about, and macOS only
  # accepts login shells listed in /etc/shells.
  users.knownUsers = [ username ];
  environment.shells = [ pkgs.fish ];

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    uid = 501;
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFUJBV5UfedJQE8qPmosVK7s1xbK+VgrhFC7qolLvPo2 mohamedshire@nixos"
    ];
  };

  # Touch ID for sudo, with the password still accepted as a fallback.
  # `reattach` lets the prompt reach the fingerprint sensor from terminals
  # that run under a multiplexer (Rex, zellij, tmux), where it otherwise
  # falls back to the password.
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  system.stateVersion = 4;
  system.primaryUser = username;
}
