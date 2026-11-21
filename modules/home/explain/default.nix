# explain: explainer diagrams and reports, viewed in Rex panes and yazi.
#
# macOS only (Rex lives there). Everything is linked *out of the store* to
# this checkout, so editing the skill, the viewer, the glow style or the
# yazi config takes effect immediately, no switch needed. The catch: the
# checkout must live at `repo` below on every Mac that uses this.
{ config, lib, pkgs, ... }:
let
  repo = "${config.home.homeDirectory}/workspace/git/dotfiles";
  here = "${repo}/modules/home/explain";
  link = path: config.lib.file.mkOutOfStoreSymlink "${here}/${path}";

  # Rex ships its CLI inside the app bundle and doesn't put it on PATH.
  rexCli = "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex";
in
lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
  home.packages = with pkgs; [
    glow      # renders markdown explainers
    librsvg   # rsvg-convert: SVG diagrams -> PNG
    jq        # explain-show reads rex's JSON
  ];

  home.file = {
    ".claude/skills/explain".source = link "skill";
    ".local/bin/explain-view".source = link "bin/explain-view";
    ".local/bin/explain-show".source = link "bin/explain-show";
    ".local/bin/rex".source = config.lib.file.mkOutOfStoreSymlink rexCli;
  };

  # yazi: gruvbox theme (matching Rex), images and explainers open in the
  # terminal, previews for markdown and coloured traces.
  xdg.configFile."yazi".source = link "yazi";
}
