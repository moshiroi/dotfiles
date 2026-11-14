# Rex (macOS terminal multiplexer). Rex's own config file, init.lua, only
# holds keybindings, so appearance lives in the app's preferences
# (com.superlogical.rex) and is set from here. Rex reads them at launch:
# quit and reopen Rex after a switch that changes them.
{ config, lib, pkgs, ... }:
let
  domain = "com.superlogical.rex";
  font = config.dotfiles.terminalFont;

  # Exported from Rex after importing "Gruvbox Material" (the Ghostty-format
  # source beside this file). Rex stores custom themes as one JSON blob.
  themes = ./custom-themes.json;
  themeID = (builtins.head (builtins.fromJSON (builtins.readFile themes))).id;
in
lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  # Kept for re-importing by hand: Settings > Themes > Import Theme.
  xdg.configFile."rex/themes/Gruvbox Material".source = ./. + "/Gruvbox Material";

  targets.darwin.defaults.${domain} = {
    "Workspace.darkThemeID" = themeID;
    "Workspace.terminalFontName" = font.family;
    "Workspace.terminalFontStyle" = font.style;
    "Workspace.terminalFontPointSize" = font.size;
    # "Improve text contrast" recolours low-contrast text, which turned the
    # cream-on-orange starship prompt black. Draw program colours as-is.
    "Workspace.terminalImproveTextContrast" = false;
  };

  # The theme blob is plist data, which targets.darwin.defaults can't
  # express. Write it only when the theme is missing, so themes added in
  # Rex's settings survive a switch.
  home.activation.rexTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    prefs=$(mktemp)
    /usr/bin/defaults export ${domain} "$prefs" 2>/dev/null || true
    current=$(/usr/libexec/PlistBuddy -c "Print :Workspace.customThemes" "$prefs" 2>/dev/null || true)
    rm -f "$prefs"
    case "$current" in
      *'${themeID}'*) ;;
      *)
        run /usr/bin/defaults write ${domain} Workspace.customThemes -data \
          "$(${pkgs.jq}/bin/jq -c . ${themes} | tr -d '\n' | /usr/bin/xxd -p | tr -d '\n')"
        ;;
    esac
  '';
}
