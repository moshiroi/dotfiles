# Noctalia: a quickshell desktop shell for niri. Replaces waybar, mako,
# swayosd and nm-applet with one design: bar, control centre (Wi-Fi,
# Bluetooth, audio), launcher with clipboard history, notifications and the
# volume OSD. Started from niri's spawn-at-startup, so Plasma never runs it.
#
# Settings are declarative: Noctalia watches ~/.config/noctalia for the
# store-path swap a rebuild does and reloads live. The flip side is that
# changes made in its settings panel can't be saved; change them here.
# Anything not set here falls back to Noctalia's defaults
# (share/noctalia-shell/Assets/settings-default.json in the package).
{ pkgs, lib, ... }:
let
  theme = import ../../theme { inherit lib; };
  p = theme.palette;

  noctalia = pkgs.noctalia-shell.overrideAttrs (old: {
    # The launcher, reworked to be compact (see ./noctalia-launcher.patch):
    #  - rows sit bare on the panel and only the selected one is
    #    highlighted, instead of every row on its own card
    #  - "compact" density (set below) is retuned: 40px single-line rows
    #    with 24px icons and regular 13px names, 2px apart. Stock compact
    #    has 16px icons and bold 15px names.
    #  - the panel is sized to its content: the search field plus exactly
    #    nine rows (13 + 38 + 13 + 9*40 + 8*2 + 13 = 453px). Stock is 600px
    #    or half the screen height, whichever is larger: 1536px on the
    #    portrait monitor.
    #  - the list/grid toggle is gone, so the search field spans the panel;
    #    it gains a search glyph and larger query text
    #  - the "N results" footer only appears to say there are no results
    # A patch rather than substituteInPlace because several hunks need
    # surrounding lines to be unique; it fails the build if upstream moves.
    patches = (old.patches or [ ]) ++ [ ./noctalia-launcher.patch ];
    # Typographic weights. Noctalia renders all text at Medium (500) and
    # headings at Bold (700), which in Inter on a dark background reads heavy.
    # macOS uses Regular for body text and Semibold for headings, so shift
    # both down a step. These are hard-coded in Style.qml with no setting;
    # --replace-fail makes the build fail loudly if an update changes them.
    postInstall = (old.postInstall or "") + ''
      substituteInPlace $out/share/noctalia-shell/Commons/Style.qml \
        --replace-fail "fontWeightMedium: 500" "fontWeightMedium: 400" \
        --replace-fail "fontWeightBold: 700" "fontWeightBold: 600"

      # Icon buttons draw their glyph in the accent colour whether they are
      # on or off, so a panel full of them is a wall of accent colour. Draw idle
      # glyphs in the text colour, as the bar already does; a toggle that is
      # on still fills with the accent, so the accent now means "active" only.
      substituteInPlace $out/share/noctalia-shell/Widgets/NIconButton.qml \
        --replace-fail "property color colorFg: Color.mPrimary" "property color colorFg: Color.mOnSurface"
      substituteInPlace $out/share/noctalia-shell/Widgets/NIconButtonHot.qml \
        --replace-fail "property color colorFg: Color.mPrimary" "property color colorFg: Color.mOnSurface"
    '';
  });

  # Panel text is sized in Qt points: 11pt body is ~14.7px, larger than the
  # 13px macOS uses. Scale panel text by 0.9 (to ~13.2px), and scale the bar
  # back up by the inverse so it stays exactly as it is.
  panelFontScale = 0.9;

  # Lichen (modules/theme) as a Noctalia colour scheme: the sage accent
  # marks only what is active; secondary roles are neutral text tones, so
  # panels carry no other hue. Picked up by name from
  # ~/.config/noctalia/colorschemes.
  schemeName = "Lichen";
  terminal = {
    normal = {
      inherit (p.term) black red green yellow blue magenta cyan white;
    };
    bright = {
      inherit (p.term) red green yellow blue magenta cyan;
      black = p.term.brightBlack;
      white = p.term.brightWhite;
    };
    inherit (p.term) foreground background;
    selectionFg = p.text;
    selectionBg = p.term.selection;
    cursorText = p.window;
    cursor = p.text;
  };
  scheme = {
    dark = {
      mPrimary = p.accent;
      mOnPrimary = p.onAccent;
      mSecondary = p.text2;
      mOnSecondary = p.window;
      mTertiary = p.text2;
      mOnTertiary = p.window;
      mError = p.error;
      mOnError = p.onAccent;
      mSurface = p.window;
      mOnSurface = p.text;
      mSurfaceVariant = p.card;
      mOnSurfaceVariant = p.text2;
      mOutline = p.hover;
      mShadow = "#0c0b0a";
      mHover = p.hover;
      mOnHover = p.text;
      inherit terminal;
    };
    # Unused (darkMode is forced on) but required by the scheme format
    light = {
      mPrimary = p.accentDim;
      mOnPrimary = "#f1ede4";
      mSecondary = "#5c584f";
      mOnSecondary = "#f1ede4";
      mTertiary = "#5c584f";
      mOnTertiary = "#f1ede4";
      mError = "#a5534b";
      mOnError = "#f1ede4";
      mSurface = "#ece8df";
      mOnSurface = "#2c2a26";
      mSurfaceVariant = "#e0dbd0";
      mOnSurfaceVariant = "#5c584f";
      mOutline = "#c9c3b6";
      mShadow = "#bdb7aa";
      mHover = "#d6d0c2";
      mOnHover = "#2c2a26";
      inherit terminal;
    };
  };

  settings = {
    # Matches the package's schema version, so Noctalia doesn't try to
    # migrate (and rewrite) the read-only file on start.
    settingsVersion = 59;

    # Laid out like the macOS menu bar: system logo and the focused app on
    # the left, status icons then the clock on the right. Workspaces sit in
    # the middle, since niri has them and macOS doesn't. No capsule behind
    # each widget (that read as a row of pills); the bar itself is the
    # surface, translucent over niri's blur.
    bar = {
      barType = "floating";
      fontScale = 1 / panelFontScale;
      position = "top";
      density = "default";
      marginVertical = 6;
      marginHorizontal = 8;
      backgroundOpacity = 0.78;
      showCapsule = false;
      widgetSpacing = 8;
      widgets = {
        left = [
          { id = "ControlCenter"; useDistroLogo = true; }
          { id = "ActiveWindow"; maxWidth = 320; }
        ];
        center = [
          { id = "Workspace"; }
        ];
        right = [
          { id = "MediaMini"; hideMode = "hidden"; maxWidth = 220; }
          { id = "Tray"; }
          { id = "Bluetooth"; }
          { id = "Network"; }
          { id = "Volume"; }
          { id = "NotificationHistory"; hideWhenZero = true; }
          { id = "Clock"; formatHorizontal = "ddd d MMM  HH:mm"; tooltipFormat = "dddd d MMMM yyyy"; }
        ];
      };
    };

    general = {
      # Only lock via Super+Alt+L (swaylock), never on suspend
      lockOnSuspend = false;
      showChangelogOnStartup = false;
      telemetryEnabled = false;
      enableShadows = true;
      # Frosted glass: niri blurs whatever is behind the translucent bar,
      # panels and notifications (ext-background-effect)
      enableBlurBehind = true;
      # Keep in step with niri's window corner radius
      radiusRatio = 1;
    };

    ui = {
      fontDefault = theme.font.ui;
      fontDefaultScale = panelFontScale;
      fontFixed = theme.font.mono;
      panelBackgroundOpacity = 0.86;
      # Panels float under the bar as their own rounded cards. Attached,
      # they grow out of the bar with concave joints, which suits a bar
      # fixed to the screen edge but not a floating one.
      panelsAttachedToBar = false;
    };

    location = {
      name = "London";
      # Don't geolocate by IP; the fixed name above is enough for weather
      autoLocate = false;
      # No animated rain/snow/stars behind the weather card; the stars read
      # as specks of noise on an otherwise flat panel
      weatherShowEffects = false;
    };

    # wpaperd draws the wallpaper (per-monitor exact-size images, see
    # modules/theme/wallpapers), so Noctalia's own wallpaper layer stays off.
    wallpaper.enabled = false;

    appLauncher = {
      # Noctalia runs the `wl-paste --watch cliphist store` watchers itself
      enableClipboardHistory = true;
      terminalCommand = "ghostty -e";
      iconMode = "native";
      position = "center";
      # A search field and results, nothing else: the row of category
      # tabs is clutter in a launcher driven by typing
      showCategories = false;
      # Single-line rows (name only), retuned by noctalia-launcher.patch.
      # Clipboard history and the other ">" modes keep their roomier rows.
      density = "compact";
      # The list/grid toggle is removed by the patch, so pin the mode
      viewMode = "list";
    };

    controlCenter.shortcuts = {
      left = [ { id = "Network"; } { id = "Bluetooth"; } ];
      right = [ { id = "Notifications"; } { id = "KeepAwake"; } { id = "NightLight"; } ];
    };

    dock.enabled = false;

    notifications = {
      location = "top_right";
      backgroundOpacity = 0.9;
    };
    osd = {
      location = "top";
      backgroundOpacity = 0.9;
    };

    # Same 10% step the media keys used before
    audio.volumeStep = 10;

    colorSchemes = {
      useWallpaperColors = false;
      predefinedScheme = schemeName;
      darkMode = true;
      syncGsettings = true;
    };

    sessionMenu.powerOptions = [
      # Locking stays on swaylock (Noctalia's lock screen needs Noctalia to
      # own the wallpaper); no swap partition, so no hibernate either.
      { action = "suspend"; enabled = true; keybind = "1"; }
      { action = "reboot"; enabled = true; keybind = "2"; }
      { action = "logout"; enabled = true; keybind = "3"; }
      { action = "shutdown"; enabled = true; keybind = "4"; }
      { action = "rebootToUefi"; enabled = true; keybind = "5"; }
    ];
  };
in {
  # Inter comes from the system font set (modules/nixos/desktop.nix)
  home.packages = [ noctalia ];

  xdg.configFile."noctalia/settings.json" = {
    text = builtins.toJSON settings;
    # Noctalia saves settings (e.g. on start, when it fills in widget
    # defaults) with an atomic rename that replaces the symlink with a plain
    # file; take it back on rebuild rather than failing once .bak exists
    force = true;
  };
  xdg.configFile."noctalia/colorschemes/${schemeName}/${schemeName}.json".text =
    builtins.toJSON scheme;

  # On a first run with existing settings, Noctalia assumes an upgrade from
  # an old version and opens a telemetry opt-in dialog over the desktop.
  # Telemetry is already off above, so record the current version as seen.
  # Only written when the state file doesn't exist; Noctalia owns it after.
  home.activation.noctaliaFirstRun = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    state="''${XDG_CACHE_HOME:-$HOME/.cache}/noctalia/shell-state.json"
    if [ ! -e "$state" ]; then
      run mkdir -p "$(dirname "$state")"
      run sh -c 'printf "%s\n" "$1" > "$2"' _ \
        '{"changelogState":{"lastSeenVersion":"${noctalia.version}"}}' "$state"
    fi
  '';
}
