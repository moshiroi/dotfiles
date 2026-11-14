# Everyday apps and which ones open what: Nautilus, mpv, swayimg, Zen,
# Anki, and fuzzel as the fallback launcher.
{ pkgs, lib, ... }:
let
  theme = import ../../theme { inherit lib; };
  p = theme.palette;
  inherit (theme) font bare;
in {
  home.packages = with pkgs; [
    anki-bin
    # File manager (Mod+E); libadwaita, so it takes the Lichen palette
    # (appearance.nix)
    nautilus
    # Video thumbnails in nautilus
    ffmpegthumbnailer
    # Full PipeWire mixer, for when the control centre's sliders aren't
    # enough (middle-click the volume icon in the bar)
    pwvucontrol
  ];

  # Video player: mpv with the uosc on-screen UI and seek-bar thumbnails
  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts; [
      uosc
      thumbfast
    ];
    config = {
      profile = "high-quality";
      vo = "gpu-next";
      hwdec = "auto-safe";
      # uosc replaces the stock OSC and title bar
      osc = "no";
      osd-bar = "no";
      border = "no";
      save-position-on-quit = true;
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = lib.genAttrs [
      "video/mp4"
      "video/x-matroska"
      "video/webm"
      "video/quicktime"
      "video/x-msvideo"
      "audio/mpeg"
      "audio/flac"
      "audio/ogg"
    ] (_: "mpv.desktop") // lib.genAttrs [
      "image/png"
      "image/jpeg"
      "image/gif"
      "image/webp"
      "image/avif"
      "image/bmp"
      "image/svg+xml"
    ] (_: "swayimg.desktop") // {
      "inode/directory" = "org.gnome.Nautilus.desktop";
    };
  };

  # Image viewer: swayimg, in Lichen to match fuzzel
  programs.swayimg = {
    enable = true;
    settings = {
      general.decoration = "no";
      viewer = {
        window = "${p.window}ff";
        scale = "optimal";
      };
      gallery = {
        size = 220;
        padding = 8;
        aspect = "fill";
        background = "${p.raised}ff";
        select = "${p.hover}ff";
        border_color = "${p.accent}ff";
        border_width = 3;
        window = "${p.window}ff";
      };
      font = {
        name = font.ui;
        size = 11;
        color = "${p.text}ff";
        shadow = "#00000000";
        background = "${p.window}cc";
      };
      info.show = "yes";
    };
  };

  programs.zen-browser.enable = true;

  # Fallback launcher (Mod+Shift+D), in Lichen like Noctalia's launcher
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "${font.ui}:size=12";
        terminal = "ghostty -e";
        width = 34;
        lines = 10;
        line-height = 26;
        horizontal-pad = 20;
        vertical-pad = 16;
        inner-pad = 10;
        icon-theme = "Gruvbox-Plus-Dark";
      };
      border = {
        # A hairline edge, as on Noctalia's panels, not a coloured frame
        width = 1;
        radius = 12;
        # Rounded highlight on the selected row, like Noctalia's launcher
        selection-radius = 8;
      };
      colors = {
        # Translucent, blurred by a niri layer rule (niri.nix). Same roles as
        # Noctalia's launcher: the selected row is a neutral raised surface
        # with unchanged text, the accent marks only the matched letters, and
        # the placeholder is dimmed.
        background = "${bare p.window}e6";
        text = "${bare p.text}ff";
        prompt = "${bare p.text3}ff";
        placeholder = "${bare p.text3}ff";
        input = "${bare p.text}ff";
        match = "${bare p.accent}ff";
        selection = "${bare p.hover}ff";
        selection-text = "${bare p.text}ff";
        selection-match = "${bare p.accent}ff";
        border = "${bare p.hover}99";
      };
    };
  };
}
