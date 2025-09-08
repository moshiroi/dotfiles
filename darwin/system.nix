{ config, pkgs, username, ... }:
let
  system = pkgs.system;
  linuxSystem = builtins.replaceStrings [ "darwin" ] [ "linux" ] system;
in {
  nixpkgs.hostPlatform = "x86_64-darwin";
  nixpkgs.config.allowUnfree = true;

  nix.linux-builder.enable = true;
  nix.linux-builder.config = {
    virtualisation.cores = 4;
  };
  
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.nushell;
  };

  system.stateVersion = 4;
  system.primaryUser = username;
}
