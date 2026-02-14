{ pkgs, ... }:
{
  nix.linux-builder.enable = true;
  nix.linux-builder.config = {
    virtualisation.cores = 4;
  };
}
