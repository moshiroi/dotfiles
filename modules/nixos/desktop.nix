{ pkgs, lib, ... }:
let
  # Shared design tokens (fonts, cursor, wallpapers) with the home layer
  theme = import ../theme { inherit lib; };
in
{
  # Niri wayland compositor - just enable for session registration
  programs.niri.enable = true;

  # Nautilus (the niri file manager): gvfs provides trash, removable-drive
  # mounting and network locations; the extension adds "Open in Ghostty"
  # to the right-click menu.
  services.gvfs.enable = true;
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "ghostty";
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      ignoreUserConfig = true;
      addons = with pkgs; [
        fcitx5-mozc # Japanese input method
      ];
      settings = {
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "keyboard-us";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "mozc";
        };
      };
    };
  };

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Typography. One family per role, installed system-wide so every toolkit
  # (GTK, Qt, Electron, the browser, SDDM) resolves the same faces instead of
  # falling back to DejaVu:
  #   UI      Inter: the closest open match to Apple's SF Pro, built for
  #           screens, with tabular figures and a large x-height
  #   Mono    JetBrains Mono (Nerd Font, for the terminal's glyphs)
  #   Serif   Source Serif 4, for documents and reader views
  #   Emoji   Noto Color Emoji; CJK falls through to Noto CJK
  fonts.packages = with pkgs; [
    inter
    source-serif
    noto-fonts-color-emoji
  ];
  fonts.fontconfig = {
    defaultFonts = {
      sansSerif = [ theme.font.ui "Noto Sans CJK JP" ];
      serif = [ theme.font.serif "Noto Serif CJK JP" ];
      monospace = [ theme.font.mono "Noto Sans Mono CJK JP" ];
      emoji = [ "Noto Color Emoji" ];
    };
    # Greyscale antialiasing with light hinting: keeps letterforms true to
    # their design (macOS doesn't snap glyphs to the pixel grid either).
    # Subpixel (RGB) AA would be sharper on the 1080p Samsung but fringes
    # colour on the rotated LG, whose subpixels run vertically.
    antialias = true;
    hinting.style = "slight";
    subpixel.rgba = "none";
  };
  # Stem darkening thickens thin strokes at small sizes the way macOS does,
  # so light text on dark backgrounds doesn't look spindly. FreeType ships
  # it disabled.
  environment.sessionVariables.FREETYPE_PROPERTIES =
    "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Login screen: the Breeze SDDM theme, but on the same wallpaper and with
  # the same font and cursor as the desktop, so login hands off seamlessly.
  # SDDM reads themes from /run/current-system/sw/share/sddm/themes, so a
  # theme.conf.user dropped in via systemPackages overrides Breeze's defaults.
  services.displayManager.sddm.settings.Theme = {
    Font = "${theme.font.ui},11";
    CursorTheme = theme.cursor.name;
    CursorSize = theme.cursor.size;
  };
  environment.systemPackages = [
    pkgs.discord
    (theme.cursor.package pkgs)
    (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      background=${pkgs.callPackage ../theme/wallpapers { }}/login.png
      type=image
    '')
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Default shell
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

}
