# Wallpapers (modules/theme/wallpapers), one per monitor via wpaperd.
{ pkgs, ... }:
let
  wallpapers = pkgs.callPackage ../../theme/wallpapers { };
in {
  # Wallpaper daemon - one source image, cut to each monitor's exact
  # resolution (see modules/theme/wallpapers). Runs as a systemd user service.
  services.wpaperd = {
    enable = true;
    settings = {
      # Matched by regex on the output description (make/model) rather than
      # the connector, for the same reason niri's output blocks are: DP-N
      # gets renumbered across kernel/driver updates. Regex sections win
      # over `any`, which covers whatever else gets plugged in.
      "re:ULTRAFINE" = { path = "${wallpapers}/portrait.png"; };
      "re:LC27RG50" = { path = "${wallpapers}/landscape.png"; };
      any = { path = "${wallpapers}/landscape.png"; };
    };
  };
}
