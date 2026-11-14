# niri: outputs, layout, window rules and keybinds, plus the tools those
# binds and startup entries run.
{ pkgs, lib, ... }:
let
  theme = import ../../theme { inherit lib; };
  p = theme.palette;
  inherit (theme) cursor;
in {
  # Niri config file
  xdg.configFile."niri/config.kdl".text = ''
    // Startup applications (wpaperd runs as a home-manager systemd user
    // service, so it is not spawned here)
    spawn-at-startup "xwayland-satellite"
    // Desktop shell: bar, control centre, launcher, notifications, OSD
    // (see noctalia.nix)
    spawn-at-startup "noctalia-shell"
    spawn-at-startup "sway-audio-idle-inhibit"
    // Polkit agent for niri; Plasma brings its own, so it is not a service
    spawn-at-startup "soteria"

    environment {
        // Qt apps (Anki, OBS, Dolphin) take their palette from the GTK theme.
        // Set here rather than in home.sessionVariables so Plasma keeps
        // its own Qt theming.
        QT_QPA_PLATFORMTHEME "gtk3"
    }

    // Monitor configuration
    // Matched by make/model/serial: connector names (DP-N) get renumbered
    // across kernel/driver updates. LG 4K is rotated portrait, left of the
    // Samsung. At scale 1.25 it is 1728x3072 logical, so x=-1728 makes the
    // edges touch and y=-996 centres it on the Samsung's 1080px height.
    output "LG Electronics LG ULTRAFINE 109NTTQ42441" {
        scale 1.25
        transform "90"
        position x=-1728 y=-996
    }
    // The Samsung is a 240Hz panel but defaults to its 60Hz preferred mode.
    output "Samsung Electric Company LC27RG50 H4ZNA01160" {
        mode "1920x1080@239.760"
        position x=0 y=0
    }

    // wpaperd's surfaces sit in the overview backdrop rather than inside
    // each workspace, so the wallpaper stays put behind zoomed-out
    // workspaces instead of a grey void. The transparent workspace
    // background below lets it show through in the normal view too.
    layer-rule {
        match namespace="^wpaperd-"
        place-within-backdrop true
    }

    // Small utility windows that make no sense tiled
    window-rule {
        match app-id=r#"^com\.saivert\.pwvucontrol$"#
        match app-id=r#"(?i)soteria"#
        match app-id=r#"^xdg-desktop-portal-gtk$"#
        open-floating true
    }

    // Rounded windows. clip-to-geometry also clips the window contents, so
    // apps that draw square corners (terminals, browsers) get rounded too.
    // 12px matches the radius of Noctalia's bar and panels.
    // The focus ring is drawn as an outline only. By default niri fills it
    // behind windows that draw their own decorations, and that fill shows
    // through any transparent margin inside the window: Electron apps such
    // as Discord keep an ~8px invisible resize border there, which turned
    // into a thick accent-coloured frame. Also needed for Ghostty's translucency.
    window-rule {
        geometry-corner-radius 12
        clip-to-geometry true
        draw-border-with-background false
    }

    // Ghostty is slightly translucent (programs.nix); blur what's behind it
    // so text stays legible. With xray (niri's default for blur) this is the
    // blurred wallpaper, computed once and reused, so it costs ~nothing.
    window-rule {
        match app-id=r#"^com\.mitchellh\.ghostty$"#
        background-effect {
            blur true
        }
    }

    // Same frosted look behind the fuzzel fallback launcher
    layer-rule {
        match namespace="^launcher$"
        background-effect {
            blur true
        }
    }

    // Visual layout settings
    layout {
        // A little more air than before, so rounded corners and shadows
        // read as separate windows rather than a grid
        gaps 10
        center-focused-column "never"
        background-color "transparent"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        // A quiet 2px sage ring: the focused window is mostly told apart
        // by its deeper shadow (below), as on macOS. Follows
        // geometry-corner-radius, so it is rounded too.
        focus-ring {
            width 2
            active-color "${p.accent}b3"
            inactive-color "${p.hover}66"
        }

        border {
            off
        }

        // Large, soft, downward shadows in the macOS style: the focused
        // window casts a deeper one, so focus reads at a glance. Costs nothing
        // in latency, unlike the animations disabled below.
        shadow {
            on
            softness 40
            spread 0
            offset x=0 y=10
            color "#00000099"
            inactive-color "#00000055"
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
        xcursor-theme "${cursor.name}"
        xcursor-size ${toString cursor.size}
        hide-when-typing
        hide-after-inactive-ms 10000
    }

    // Use custom decorations
    prefer-no-csd

    // The shortcut cheat sheet is still on Mod+Shift+Slash; don't pop it
    // up on every login
    hotkey-overlay {
        skip-at-startup
    }

    binds {
        Mod+Shift+Slash { show-hotkey-overlay; }
        Mod+T hotkey-overlay-title="Open a Terminal: ghostty" { spawn "ghostty"; }
        Mod+D hotkey-overlay-title="Run an Application" { spawn "noctalia-shell" "ipc" "call" "launcher" "toggle"; }
        Mod+Shift+D hotkey-overlay-title="Run an Application: fuzzel" { spawn "fuzzel"; }
        Mod+N hotkey-overlay-title="Control centre" { spawn "noctalia-shell" "ipc" "call" "controlCenter" "toggle"; }
        Mod+Shift+N hotkey-overlay-title="Notification history" { spawn "noctalia-shell" "ipc" "call" "notifications" "toggleHistory"; }
        Super+Alt+L hotkey-overlay-title="Lock the Screen: swaylock" { spawn "swaylock"; }
        Super+Alt+Z hotkey-overlay-title="Sleep" { spawn "systemctl" "suspend"; }
        Super+Alt+S hotkey-overlay-title=null { spawn "sh" "-c" "pkill orca || exec orca"; }
        Mod+E hotkey-overlay-title="Files: nautilus" { spawn "nautilus" "--new-window"; }
        Mod+Ctrl+V hotkey-overlay-title="Clipboard history" { spawn "noctalia-shell" "ipc" "call" "launcher" "clipboard"; }

        // Volume through Noctalia, so the change shows in its OSD
        XF86AudioRaiseVolume allow-when-locked=true { spawn "noctalia-shell" "ipc" "call" "volume" "increase"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "noctalia-shell" "ipc" "call" "volume" "decrease"; }
        XF86AudioMute        allow-when-locked=true { spawn "noctalia-shell" "ipc" "call" "volume" "muteOutput"; }
        XF86AudioMicMute     allow-when-locked=true { spawn "noctalia-shell" "ipc" "call" "volume" "muteInput"; }

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
        Mod+Return { fullscreen-window; }

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

        // Screen recording: press once to pick a region and start, again to stop
        Mod+Shift+X hotkey-overlay-title="Screen record: select region (toggle)" { spawn "sh" "-c" "pgrep -x wf-recorder >/dev/null && pkill -INT -x wf-recorder || { mkdir -p ~/Videos/Screencasts && wf-recorder -g \"$(slurp)\" -f ~/Videos/Screencasts/rec-$(date +%F-%H%M%S).mp4; }"; }

        Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

        Mod+Shift+E { quit; }
        Ctrl+Alt+Delete { quit; }

        Mod+Shift+P { power-off-monitors; }
    }
  '';

  # Spawned at niri startup or by its keybinds
  home.packages = with pkgs; [
    # Polkit agent (spawned at niri startup)
    soteria
    # Inhibits idle when audio is playing (spawned at niri startup)
    sway-audio-idle-inhibit
    gnome-keyring
    # XWayland support for niri
    xwayland-satellite
    # Clipboard-specific
    wl-clipboard
    cliphist
    # Screenshots
    grim
    slurp
    # Screen recording (Mod+Shift+X)
    wf-recorder
    # XWayland/Wayland
    wlr-randr
    wayland-utils
    xcb-util-cursor
    libxcb
    xprop
    xkbcomp
  ];
}
