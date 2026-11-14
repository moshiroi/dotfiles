# The niri desktop on jarvis: one module per concern. Colours, fonts and the
# cursor come from the shared theme (modules/theme); nothing here hard-codes
# them.
{ zen-browser, pkgs, ... }: {
  imports = [
    zen-browser.homeModules.beta
    ./niri.nix
    ./noctalia.nix
    ./appearance.nix
    ./apps.nix
    ./wallpaper.nix
    ./lock.nix
  ];

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
}
