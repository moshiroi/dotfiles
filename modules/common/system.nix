{
  pkgs,
  ...
}:
{
  fonts.packages = [ pkgs.nerd-fonts.iosevka-term ];
  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

}
