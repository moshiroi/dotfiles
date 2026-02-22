{ zen-browser, pkgs, ... }: {
  imports = [ zen-browser.homeModules.beta ];

  # Niri config file
  xdg.configFile."niri/config.kdl".text = ''
    // Startup applications
    spawn-at-startup "xwayland-satellite"
    spawn-at-startup "waybar"
    spawn-at-startup "wpaperd"
    spawn-at-startup "nm-applet"
    spawn-at-startup "sway-audio-idle-inhibit"

    // Monitor configuration
    output "DP-5" {
        transform "90"
        position x=-2160 y=-1300
    }

    // Visual layout settings
    layout {
        gaps 6
        center-focused-column "never"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        // Gruvbox-themed focus ring
        focus-ring {
            width 4
            active-color "#83a598"
            inactive-color "#665c54"
        }

        border {
            off
        }
    }

    // Disable animations for snappy feel
    animations {
        workspace-switch { off; }
        window-open { off; }
        window-close { off; }
    }

    // Cursor behavior
    cursor {
        hide-when-typing
        hide-after-inactive-ms 10000
    }

    // Use custom decorations
    prefer-no-csd

    binds {
        Mod+Shift+Slash { show-hotkey-overlay; }
        Mod+T hotkey-overlay-title="Open a Terminal: alacritty" { spawn "alacritty"; }
        Mod+D hotkey-overlay-title="Run an Application: fuzzel" { spawn "fuzzel"; }
        Super+Alt+L hotkey-overlay-title="Lock the Screen: swaylock" { spawn "swaylock"; }
        Super+Alt+S hotkey-overlay-title=null { spawn "sh" "-c" "pkill orca || exec orca"; }

        XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"; }
        XF86AudioMute        allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioMicMute     allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

        XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }

        Mod+O repeat=false { toggle-overview; }
        Mod+Q repeat=false { close-window; }

        Mod+Left  { focus-column-left; }
        Mod+Down  { focus-window-down; }
        Mod+Up    { focus-window-up; }
        Mod+Right { focus-column-right; }
        Mod+H     { focus-column-left; }
        Mod+J     { focus-window-down; }
        Mod+K     { focus-window-up; }
        Mod+L     { focus-column-right; }

        Mod+Ctrl+Left  { move-column-left; }
        Mod+Ctrl+Down  { move-window-down; }
        Mod+Ctrl+Up    { move-window-up; }
        Mod+Ctrl+Right { move-column-right; }
        Mod+Ctrl+H     { move-column-left; }
        Mod+Ctrl+J     { move-window-down; }
        Mod+Ctrl+K     { move-window-up; }
        Mod+Ctrl+L     { move-column-right; }

        Mod+Home { focus-column-first; }
        Mod+End  { focus-column-last; }
        Mod+Ctrl+Home { move-column-to-first; }
        Mod+Ctrl+End  { move-column-to-last; }

        Mod+Shift+Left  { focus-monitor-left; }
        Mod+Shift+Down  { focus-monitor-down; }
        Mod+Shift+Up    { focus-monitor-up; }
        Mod+Shift+Right { focus-monitor-right; }
        Mod+Shift+H     { focus-monitor-left; }
        Mod+Shift+J     { focus-monitor-down; }
        Mod+Shift+K     { focus-monitor-up; }
        Mod+Shift+L     { focus-monitor-right; }

        Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
        Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
        Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
        Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
        Mod+Shift+Ctrl+H     { move-column-to-monitor-left; }
        Mod+Shift+Ctrl+J     { move-column-to-monitor-down; }
        Mod+Shift+Ctrl+K     { move-column-to-monitor-up; }
        Mod+Shift+Ctrl+L     { move-column-to-monitor-right; }

        Mod+Page_Down      { focus-workspace-down; }
        Mod+Page_Up        { focus-workspace-up; }
        Mod+U              { focus-workspace-down; }
        Mod+I              { focus-workspace-up; }
        Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
        Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
        Mod+Ctrl+U         { move-column-to-workspace-down; }
        Mod+Ctrl+I         { move-column-to-workspace-up; }

        Mod+Shift+Page_Down { move-workspace-down; }
        Mod+Shift+Page_Up   { move-workspace-up; }
        Mod+Shift+U         { move-workspace-down; }
        Mod+Shift+I         { move-workspace-up; }

        Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
        Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
        Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
        Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

        Mod+WheelScrollRight      { focus-column-right; }
        Mod+WheelScrollLeft       { focus-column-left; }
        Mod+Ctrl+WheelScrollRight { move-column-right; }
        Mod+Ctrl+WheelScrollLeft  { move-column-left; }

        Mod+Shift+WheelScrollDown      { focus-column-right; }
        Mod+Shift+WheelScrollUp        { focus-column-left; }
        Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
        Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+Ctrl+1 { move-column-to-workspace 1; }
        Mod+Ctrl+2 { move-column-to-workspace 2; }
        Mod+Ctrl+3 { move-column-to-workspace 3; }
        Mod+Ctrl+4 { move-column-to-workspace 4; }
        Mod+Ctrl+5 { move-column-to-workspace 5; }
        Mod+Ctrl+6 { move-column-to-workspace 6; }
        Mod+Ctrl+7 { move-column-to-workspace 7; }
        Mod+Ctrl+8 { move-column-to-workspace 8; }
        Mod+Ctrl+9 { move-column-to-workspace 9; }

        Mod+BracketLeft  { consume-or-expel-window-left; }
        Mod+BracketRight { consume-or-expel-window-right; }

        Mod+Comma  { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+Ctrl+R { reset-window-height; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }

        Mod+Ctrl+F { expand-column-to-available-width; }

        Mod+C { center-column; }
        Mod+Ctrl+C { center-visible-columns; }

        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }

        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        Mod+V       { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }

        Mod+W { toggle-column-tabbed-display; }

        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }

        // Screenshot alternatives (no PrintScreen key)
        Mod+Shift+S hotkey-overlay-title="Screenshot: select region to clipboard" { spawn "sh" "-c" "grim -g \"$(slurp)\" - | wl-copy"; }
        Mod+Shift+A hotkey-overlay-title="Screenshot: full screen to clipboard" { spawn "sh" "-c" "grim - | wl-copy"; }

        Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

        Mod+Shift+E { quit; }
        Ctrl+Alt+Delete { quit; }

        Mod+Shift+P { power-off-monitors; }
    }
  '';

  # Only show xwaylandvideobridge in KDE, not in niri
  xdg.configFile."autostart/org.kde.xwaylandvideobridge.desktop".text = ''
    [Desktop Entry]
    Name=Xwayland Video Bridge
    Exec=xwaylandvideobridge
    Type=Application
    OnlyShowIn=KDE;
  '';

  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
  ];

  # Used Packages
  home.packages = with pkgs; [
    # PipeWire-native volume control GUI (switch audio outputs, manage streams)
    pwvucontrol
    # Inhibits idle when audio is playing (spawned at niri startup)
    sway-audio-idle-inhibit
    gnome-keyring
    # NetworkManager applet for system tray
    networkmanagerapplet
    # XWayland support for niri
    xwayland-satellite
    # Clipboard-specific
    wl-clipboard
    cliphist
    # Screenshots
    grim
    slurp
    # Image Viewer
    imv
    # XWayland/Wayland
    wlr-randr
    wayland-utils
    xcb-util-cursor
    xorg.libxcb
    xorg.xprop
    xorg.xkbcomp
  ];

  programs.zen-browser.enable = true;

  # Application launcher (Mod+D) - Owlphin-style Gruvbox
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=11";
        terminal = "alacritty -e";
        width = 20;
        lines = 15;
      };
      border = {
        radius = 0;
      };
      colors = {
        background = "282828ff";
        text = "ebdbb2ff";
        prompt = "ebdbb2ff";
        placeholder = "ebdbb2ff";
        input = "ebdbb2ff";
        match = "ebdbb2ff";
        selection = "ebdbb2ff";
        selection-text = "282828ff";
        selection-match = "282828ff";
        border = "d65d0eff";
      };
    };
  };

  # Waybar status bar - kaju-style Gruvbox (solid, clean, icon-only)
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        reload_style_on_change = true;
        layer = "top";
        position = "top";
        spacing = 0;
        height = 26;

        modules-left = [ "niri/workspaces" "niri/window" ];
        modules-center = [ "clock" ];
        modules-right = [
          "group/tray-expander"
          "mpris"
          "network"
          "wireplumber"
          "cpu"
        ];

        "niri/workspaces" = {
          format = "{icon}";
          format-icons = {
            default = "";
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            active = "󱓻";
          };
        };

        "niri/window" = {
          format = "{}";
          max-length = 50;
          separate-outputs = false;
        };

        clock = {
          format = "{:L%A %H:%M}";
          format-alt = "{:L%d %B %Y}";
          tooltip = false;
        };

        cpu = {
          interval = 5;
          format = "󰍛";
          tooltip-format = "{usage}%";
        };

        network = {
          format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
          format = "{icon}";
          format-wifi = "{icon}";
          format-ethernet = "󰀂";
          format-disconnected = "󰤮";
          tooltip-format-wifi = "{essid} ({frequency} GHz)\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-ethernet = "⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          tooltip-format-disconnected = "Disconnected";
          interval = 3;
          spacing = 1;
        };

        wireplumber = {
          format = "{icon}";
          on-click = "pwvucontrol";
          tooltip-format = "{volume}%";
          scroll-step = 5;
          format-muted = "󰝟";
          format-icons = [ "󰕿" "󰖀" "󰕾" ];
        };

        mpris = {
          format = "{status_icon}";
          format-paused = "{status_icon}";
          tooltip-format = "{artist} — {title}";
          status-icons = {
            playing = "󰐊";
            paused = "󰏤";
            stopped = "";
          };
        };

        "group/tray-expander" = {
          orientation = "inherit";
          drawer = {
            transition-duration = 600;
            children-class = "tray-group-item";
          };
          modules = [ "custom/expand-icon" "tray" ];
        };

        "custom/expand-icon" = {
          format = "󰅁";
          tooltip = false;
        };

        tray = {
          icon-size = 12;
          spacing = 17;
        };
      };
    };
    style = ''
      @define-color fg #ebdbb2;
      @define-color bg #282828;

      * {
        background-color: @bg;
        color: @fg;
        border: none;
        border-radius: 0;
        min-height: 0;
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
      }

      .modules-left {
        margin-left: 8px;
      }

      .modules-right {
        margin-right: 8px;
      }

      #workspaces button {
        all: initial;
        padding: 0 6px;
        margin: 0 1.5px;
        min-width: 9px;
      }

      #workspaces button.empty {
        opacity: 0.5;
      }

      #cpu,
      #wireplumber,
      #mpris,
      #network {
        min-width: 12px;
        margin: 0 7.5px;
      }

      #window {
        margin-left: 12px;
        opacity: 0.7;
      }

      #tray {
        margin-right: 16px;
      }

      #bluetooth {
        margin-right: 17px;
      }

      #network {
        margin-right: 13px;
      }

      #custom-expand-icon {
        margin-right: 20px;
      }

      tooltip {
        padding: 2px;
      }

      .hidden {
        opacity: 0;
      }
    '';
  };

  # Wallpaper daemon - separate wallpapers per monitor
  services.wpaperd = {
    enable = true;
    settings = {
      # Main monitor (Samsung 1080p landscape)
      DP-6 = { path = "${./wallpapers/landscape.png}"; };
      # Secondary monitor (LG 4K portrait/rotated)
      DP-5 = { path = "${./wallpapers/portrait.png}"; };
    };
  };

  # Screen locker - Gruvbox styled
  programs.swaylock = {
    enable = true;
    settings = {
      color = "282828";
      inside-color = "28282800";
      inside-clear-color = "28282800";
      inside-ver-color = "28282800";
      inside-wrong-color = "28282800";
      ring-color = "3c3836";
      ring-clear-color = "fabd2f";
      ring-ver-color = "83a598";
      ring-wrong-color = "fb4934";
      key-hl-color = "d65d0e";
      bs-hl-color = "fb4934";
      text-color = "ebdbb2";
      text-clear-color = "fabd2f";
      text-ver-color = "83a598";
      text-wrong-color = "fb4934";
      line-color = "00000000";
      line-clear-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";
      separator-color = "00000000";
      indicator-radius = 100;
      indicator-thickness = 10;
      font = "JetBrainsMono Nerd Font";
      font-size = 24;
      show-failed-attempts = true;
      ignore-empty-password = true;
      daemonize = true;
    };
  };

  # Idle daemon - locks screen and powers off monitors
  services.swayidle = {
    enable = true;
    systemdTarget = "graphical-session.target";
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock";
      }
      {
        timeout = 600;
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock";
      }
      {
        event = "lock";
        command = "${pkgs.swaylock}/bin/swaylock";
      }
    ];
  };
}
