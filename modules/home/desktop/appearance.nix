# Toolkit theming: GTK 3 (recoloured Gruvbox-Dark), GTK 4 / libadwaita (a
# palette override), icons, cursor and the portal-visible dconf settings, so
# every app draws in Lichen whatever toolkit it uses.
{ pkgs, lib, ... }:
let
  theme = import ../../theme { inherit lib; };
  p = theme.palette;
  inherit (theme) font cursor rgb;

  # libadwaita (Nautilus, pwvucontrol, soteria) ignores GTK themes but reads
  # ~/.config/gtk-4.0/gtk.css, so recolour it through its named colours
  # rather than importing a full third-party stylesheet that can break on
  # libadwaita updates. Emitted both as CSS variables (libadwaita >= 1.6
  # reads `--window-bg-color`) and as @define-color for older GTK 4 apps.
  adwaita = {
    accent-bg = p.accent;
    accent-fg = p.onAccent;
    accent = p.accent;
    destructive-bg = p.error;
    destructive-fg = p.onAccent;
    destructive = p.error;
    success-bg = p.success;
    success-fg = p.onAccent;
    success = p.success;
    warning-bg = p.warning;
    warning-fg = p.onAccent;
    warning = p.warning;
    error-bg = p.error;
    error-fg = p.onAccent;
    error = p.error;
    window-bg = p.window;
    window-fg = p.text;
    view-bg = p.well;
    view-fg = p.text;
    headerbar-bg = p.raised;
    headerbar-fg = p.text;
    headerbar-backdrop = p.window;
    sidebar-bg = p.raised;
    sidebar-fg = p.text;
    sidebar-backdrop = p.window;
    secondary-sidebar-bg = p.window;
    secondary-sidebar-fg = p.text;
    secondary-sidebar-backdrop = p.window;
    card-bg = p.card;
    card-fg = p.text;
    dialog-bg = p.raised;
    dialog-fg = p.text;
    popover-bg = p.card;
    popover-fg = p.text;
    thumbnail-bg = p.card;
    thumbnail-fg = p.text;
  };
  adwaitaCss = ''
    :root {
    ${lib.concatStrings
      (lib.mapAttrsToList (n: v: "  --${n}-color: ${v};\n") adwaita)}}
    ${lib.concatStrings (lib.mapAttrsToList
      (n: v: "@define-color ${lib.replaceStrings [ "-" ] [ "_" ] n}_color ${v};\n")
      adwaita)}
  '';
in {
  # GTK theming. GTK 3 apps (file pickers, older tools) get the full
  # Gruvbox-Dark theme; GTK 4 / libadwaita apps get only the palette
  # override above, since importing a whole theme into libadwaita is
  # unsupported and tends to break on upgrades.
  gtk = {
    enable = true;
    colorScheme = "dark";
    # Same UI font as Noctalia. 10pt is 13.3px at 96 DPI, the size macOS
    # uses for its own UI text.
    font = {
      name = font.ui;
      size = 10;
    };
    theme = {
      name = "Gruvbox-Dark";
      # Gruvbox-Dark is the GTK 3 base (nm file pickers, Zen and Qt apps
      # take their colours from it), recoloured to Lichen at build time:
      # its cream text, teal accent and warm greys are each mapped to the
      # nearest Lichen role, in both #hex and rgba() forms. The grep checks
      # make the build fail if an update changes the theme's colours.
      package = let
        recolour = [
          [ "#fbf1c7" p.text ]
          [ "#7daea3" p.accent ]
          [ "#45707a" p.accentDim ]
          [ "#638880" p.accentDim ]
          [ "#77a59b" p.accent ]
          [ "#1d2021" p.window ]
          [ "#282524" p.raised ]
          [ "#242220" p.raised ]
          [ "#423f3e" p.hover ]
          [ "#504945" p.hover ]
          [ "#141617" p.well ]
          [ "#161819" p.well ]
          [ "#0f0e0e" p.well ]
          [ "#c14a4a" p.error ]
          [ "#b47109" p.warning ]
          [ "#e78a4e" p.warning ]
        ];
        # rgba() in the theme may or may not have spaces after commas
        sedArgs = lib.concatMapStringsSep " " (pair:
          let
            from = builtins.elemAt pair 0;
            to = builtins.elemAt pair 1;
            pat = lib.replaceStrings [ ", " ] [ ", *" ] (rgb from);
          in "-e 's/${from}/${to}/gI' -e 's/rgba(${pat},/rgba(${rgb to},/g'")
          recolour;
      in pkgs.gruvbox-gtk-theme.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          css=$out/share/themes/Gruvbox-Dark/gtk-3.0/gtk.css
          # Not `a && b`: set -e ignores a failure on the left of &&
          for c in '#fbf1c7' '#7daea3'; do
            grep -q -i "$c" $css \
              || { echo "gruvbox-gtk-theme: $c not in $css" >&2; exit 1; }
          done
          find $out/share/themes -type f \
            \( -name '*.css' -o -name '*.svg' -o -name '*rc' \) \
            -exec sed -i ${sedArgs} {} +
        '';
      });
    };
    iconTheme = {
      name = "Gruvbox-Plus-Dark";
      # Warm grey folders: quiet, and they don't compete with the accent
      package = pkgs.gruvbox-plus-icons.override { folder-color = "grey"; };
    };
    # Our stateVersion predates 26.05, where gtk4.theme stopped inheriting
    # gtk.theme. Opt out explicitly and use the palette instead.
    gtk4.theme = null;
    gtk4.extraCss = adwaitaCss;
  };

  # Desktop-wide appearance settings. libadwaita apps, Zen and Electron
  # read these through the settings portal rather than settings.ini, so the
  # font roles and rendering are set here too, matching fontconfig.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      # For apps that don't load our CSS: libadwaita's fixed accents are all
      # saturated except slate, the least intrusive at night
      accent-color = "slate";
      font-name = "${font.ui} 10";
      document-font-name = "${font.serif} 11";
      monospace-font-name = "${font.mono} 10";
      font-antialiasing = "grayscale";
      font-hinting = "slight";
    };
    # Tiling WM: windows are closed with Mod+Q and never minimised or
    # maximised by button, so headerbars keep only a close button
    "org/gnome/desktop/wm/preferences".button-layout = ":close";
    # Folders before files, as in Finder, in Nautilus and file pickers
    "org/gtk/gtk4/settings/file-chooser".sort-directories-first = true;
    "org/gtk/settings/file-chooser".sort-directories-first = true;
  };

  home.pointerCursor = {
    inherit (cursor) name size;
    package = cursor.package pkgs;
    gtk.enable = true;
    x11.enable = true;
  };
}
