# Wallpapers: one manga piece per monitor, chosen for its shape, then
# duotoned into Lichen (../palette.nix) so the art reads as part of the
# desktop rather than a photo pasted behind it.
#
#   Portrait LG (2160x3840)   Berserk: Guts under the full moon
#   Landscape Samsung (1080p) Chi. Chikyuu no Undou ni Tsuite: Rafał
#                             standing in the dark, on the right so the
#                             left of the screen stays open for windows
#
# The images are fan art, fetched at build time and pinned by hash rather
# than committed: the artwork belongs to its artists and this repo is
# public. Everything else (crop, tint, fade) happens here, so changing the
# look is a rebuild, not an image edit.
{ runCommandLocal, fetchurl, imagemagick }:
let
  p = import ../palette.nix;

  guts = fetchurl {
    # wallhaven.cc/w/e882e8, 4751x8444 (already 9:16)
    url = "https://w.wallhaven.cc/full/e8/wallhaven-e882e8.jpg";
    hash = "sha256-7/Mya5U4JdDFMN+DDAz0S9/uVH/kI/Do0MV7jlxN24g=";
  };
  rafal = fetchurl {
    # safebooru.org post 6384942, 1396x1954, on a black background
    url = "https://safebooru.org/images/41/d7523a140c98c44025cde3586f0c5a36b44c8b87.jpg";
    hash = "sha256-jOtabKwpmHi3MHCU8LIIyDBu76EBewz/Qdre2ufw+YE=";
  };

  # Duotone: black maps to the darkest Lichen surface and white to the
  # secondary text tone, not full bone, so nothing on the desktop outshines
  # the UI text in a dim room. Raise `light` to p.text for more punch.
  dark = p.well;
  light = p.text2;
in
runCommandLocal "wallpapers" { nativeBuildInputs = [ imagemagick ]; } ''
  mkdir -p $out
  tint() {
    magick "$1" -colorspace gray -normalize \
      +level-colors '${dark}','${light}' "$2"
  }

  # Portrait: Guts is already 9:16, so this is a straight high-quality
  # downscale to the LG's physical resolution.
  # Downscale first, so the tint works on 8MP rather than the 40MP original.
  magick ${guts} -gravity center -crop 9:16 +repage \
    -filter Lanczos -resize 2160x3840! guts.png
  tint guts.png $out/portrait.png

  # Landscape: Rafał at full height, set right of centre on the background
  # colour. His black background tints to exactly that colour, and a soft
  # mask fades the left 35% of the art (plus 8% top and bottom), so there is
  # no visible edge.
  tint ${rafal} rafal.png
  landscape() { # width height output
    w=$1 h=$2
    magick rafal.png -filter Lanczos -resize x"$h" art.png
    aw=$(magick identify -format %w art.png)
    magick -size "$h"x"$aw" gradient:black-white -rotate -90 -level 0,35% fade-x.png
    magick -size "$aw"x"$h" gradient:black-white -level 0,8% \
      \( -size "$aw"x"$h" gradient:white-black -level 0,8% \) \
      -compose multiply -composite fade-y.png
    magick fade-x.png fade-y.png -compose multiply -composite mask.png
    magick art.png mask.png -alpha off -compose copyopacity -composite art-a.png
    magick -size "$w"x"$h" xc:'${dark}' art-a.png \
      -gravity east -geometry +$((w / 19))+0 -compose over -composite "$3"
  }
  landscape 1920 1080 $out/landscape.png
  # SDDM login: one image for both monitors, rendered at 4K
  landscape 3840 2160 $out/login.png

  # Lock screen: the landscape, blurred and dimmed further so the swaylock
  # ring stays the focus
  magick $out/landscape.png -blur 0x24 \
    -fill '${dark}' -colorize 35% $out/lock.png
''
