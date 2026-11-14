# Design tokens for the whole setup: colour, type and cursor in one place,
# read by both the NixOS layer (fontconfig, SDDM) and Home Manager (niri,
# Noctalia, GTK, the terminal). Plain data plus two colour helpers, so any
# module can `import` it without going through the module system.
{ lib }:
{
  # Lichen, the one palette (./palette.nix)
  palette = import ./palette.nix;

  # Type roles. fontconfig's defaults (modules/nixos/desktop.nix) and every
  # app that names a font explicitly use these.
  font = {
    ui = "Inter";
    mono = "JetBrainsMono Nerd Font";
    serif = "Source Serif 4";
  };

  # Apple's own macOS cursor set, on the desktop and the SDDM login screen.
  # `package` takes pkgs, so this file stays free of a pkgs dependency.
  cursor = {
    name = "macOS";
    size = 24;
    package = pkgs: pkgs.apple-cursor;
  };

  # "#rrggbb" -> "r, g, b", for rgba() forms in theme rewrites
  rgb = hex: lib.concatMapStringsSep ", "
    (i: toString (lib.fromHexString (builtins.substring i 2 hex))) [ 1 3 5 ];
  # "#rrggbb" -> "rrggbb", for fuzzel and swaylock, which take bare hex
  bare = lib.removePrefix "#";
}
