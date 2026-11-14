# Locking: swaylock on Super+Alt+L only, never on idle or suspend.
{ pkgs, lib, ... }:
let
  theme = import ../../theme { inherit lib; };
  p = theme.palette;
  inherit (theme) font bare;
  wallpapers = pkgs.callPackage ../../theme/wallpapers { };
in {
  # Screen locker: blurred wallpaper with a slim Lichen ring
  programs.swaylock = {
    enable = true;
    settings = {
      # Blurred, dimmed wallpaper; `color` is the fallback if it fails to load
      image = "${wallpapers}/lock.png";
      scaling = "fill";
      color = bare p.window;
      inside-color = "${bare p.well}99";
      inside-clear-color = "${bare p.well}99";
      inside-ver-color = "${bare p.well}99";
      inside-wrong-color = "${bare p.well}99";
      ring-color = "${bare p.text}1f";
      ring-clear-color = bare p.text2;
      ring-ver-color = bare p.accent;
      ring-wrong-color = bare p.error;
      key-hl-color = bare p.accent;
      bs-hl-color = bare p.error;
      text-color = bare p.text;
      text-clear-color = bare p.text2;
      text-ver-color = bare p.accent;
      text-wrong-color = bare p.error;
      line-color = "00000000";
      line-clear-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";
      separator-color = "00000000";
      # A slim ring and light type over the blurred wallpaper
      indicator-radius = 90;
      indicator-thickness = 5;
      font = font.ui;
      font-size = 20;
      show-failed-attempts = true;
      ignore-empty-password = true;
      daemonize = true;
    };
  };

  # Idle daemon disabled: the screen should only lock via the manual
  # Super+Alt+L keybind (which spawns swaylock directly, see niri.nix),
  # never automatically — no idle timeout, no lock-on-suspend.
  services.swayidle.enable = false;
}
