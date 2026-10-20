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
  programs.fish.enable = true;

  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.trusted-users = [ username ];
  };

  # eMudhra's emSign intermediate CA keys were recoverable (2026-10-17,
  # https://emudhra.we-have-a-problem.com/). Browsers blocked them, but
  # curl, OpenSSL, Rust and Python trust this bundle and check no
  # revocation. Drop once nixpkgs ships cacert 3.131.1, which removes
  # the emSign root itself.
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
    "emSign ECC Root CA - G3"
  ];
}
