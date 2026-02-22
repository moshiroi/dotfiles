{
  pkgs,
  username,
  ...
}:
{
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
  ];
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "DejaVu Sans" "Noto Sans CJK JP" ];
    serif = [ "DejaVu Serif" "Noto Serif CJK JP" ];
  };
  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.trusted-users = [ username ];
  };

}
