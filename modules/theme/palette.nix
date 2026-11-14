# Lichen: the desktop palette, and the only place colours are defined.
#
# Warm charcoal surfaces, bone text and a single sage accent, tuned for dim
# rooms: no pure black or white, low saturation throughout, and text kept
# neutral so the accent is the only hue. Every module that sets a colour
# (niri, Noctalia, GTK 3/4, ghostty, zellij, fuzzel, swaylock, swayimg, the
# wallpaper) reads it from here.
#
# Contrast on `window`: text 10.7:1, text2 6.5:1, text3 3.6:1, accent 6.3:1.
rec {
  # Surfaces, darkest to lightest. Each step is one level of elevation.
  well = "#191816"; # recessed: list/content views, terminal-adjacent wells
  window = "#201f1d"; # windows, panels, terminal background
  raised = "#282724"; # headerbars, sidebars, the bar
  card = "#32302d"; # cards, popovers, menus
  hover = "#444139"; # hover, selection, outlines

  # Text, three levels
  text = "#d6d0c2"; # primary
  text2 = "#a8a295"; # secondary: subtitles, inactive labels
  text3 = "#78746a"; # tertiary: placeholders, hints, disabled

  # The one accent: focus, "on" toggles, selection, primary buttons
  accent = "#98a585";
  accentDim = "#5f6a52"; # accent as a background tint
  onAccent = "#1b1c17"; # text drawn on accent (6.6:1)

  # Semantic colours, muted to sit with the accent
  error = "#c8776f";
  warning = "#bfa36f";
  success = accent;

  # Terminal: Gruvbox Material hues (Gruvbox's colours in the same slots,
  # desaturated) on Lichen's surfaces, so code still reads like Gruvbox but
  # nothing glares.
  term = {
    black = card;
    red = "#ea6962";
    green = "#a9b665";
    yellow = "#d8a657";
    blue = "#7daea3";
    magenta = "#d3869b";
    cyan = "#89b482";
    white = text2;
    brightBlack = "#857f73"; # comments, autosuggestions
    brightWhite = text;
    background = window;
    foreground = text;
    selection = hover;
  };
}
