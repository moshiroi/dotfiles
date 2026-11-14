# Starship prompt in Lichen (./palette.nix): one rounded pill on a subtle
# surface, the same capsule language as the Noctalia bar. The text carries
# the information, not filled blocks: directory in bold bone, git branch in
# sage, changes in amber, toolchains in teal, with hairline dividers. The
# clock and command duration sit dimmed in the right prompt, and the input
# line starts with a sage ❯ that turns red after a failing command.
#
# Colours go through a starship palette rather than literal hex, so
# remote-theme.nix can recolour the pill for SSH sessions by overriding
# `surface` and `accent`.
p:
let
  # Nerd Font glyphs by codepoint. They live in Unicode's private-use area,
  # which doesn't survive copy/paste reliably, and Nix strings have no \u
  # escape, so decode them from JSON instead.
  g = hex: builtins.fromJSON "\"\\u${hex}\"";
  capL = g "e0b6"; # left half-circle
  capR = g "e0b4"; # right half-circle
  # One segment inside the pill, preceded by a hairline divider. The divider
  # lives inside the segment's format, so it disappears when the segment does.
  seg = colour: body:
    "[ │ ](fg:divider bg:surface)[${body}](fg:${colour} bg:surface)";
  lang = symbol: {
    inherit symbol;
    format = seg "info" "$symbol( $version)";
  };
in
{
  format = builtins.concatStringsSep "" [
    "[${capL}](fg:surface)"
    "$os"
    "$username"
    "$hostname"
    "$directory"
    "$git_branch"
    "$git_state"
    "$git_status"
    "$nix_shell"
    "$c"
    "$rust"
    "$golang"
    "$nodejs"
    "$python"
    "$java"
    "$kotlin"
    "$haskell"
    "$php"
    "$docker_context"
    "$conda"
    "[ ](bg:surface)[${capR}](fg:surface)"
    "$line_break"
    "$character"
  ];
  right_format = "$cmd_duration$time";
  add_newline = true;

  palette = "lichen";
  palettes.lichen = {
    surface = p.card;
    divider = p.hover;
    text = p.text;
    text_dim = p.text2;
    accent = p.accent;
    warn = p.warning;
    err = p.error;
    info = p.term.blue;
  };

  os = {
    disabled = false;
    format = "[$symbol ](fg:accent bg:surface)";
    symbols = {
      NixOS = g "f313";
      Macos = g "f179";
      Linux = g "f17c";
      Ubuntu = g "f31b";
      Debian = g "f306";
      Arch = g "f303";
      Fedora = g "f30a";
    };
  };

  # Only when it matters: over SSH, or as root
  username = {
    show_always = false;
    format = "[$user](fg:text_dim bg:surface)";
  };
  hostname = {
    ssh_only = true;
    format = "[@$hostname ](fg:text_dim bg:surface)";
  };

  directory = {
    format = "[$path](bold fg:text bg:surface)[$read_only](fg:warn bg:surface)";
    read_only = " ${g "f023"}";
    truncation_length = 3;
    truncation_symbol = "…/";
  };

  git_branch = {
    symbol = g "f418";
    format = seg "accent" "$symbol $branch";
  };
  git_state.format = "[ $state( $progress_current/$progress_total)](fg:warn bg:surface)";
  git_status.format = "([ $all_status$ahead_behind](fg:warn bg:surface))";

  # A small marker inside direnv / `nix develop` shells, detected through
  # IN_NIX_SHELL; the PATH heuristic misfires on NixOS, where /nix/store
  # paths are everywhere
  nix_shell = {
    symbol = g "f313";
    format = seg "info" "$symbol( $name)";
    heuristic = false;
  };

  c = lang (g "e61e");
  rust = lang (g "e7a8");
  golang = lang (g "e627");
  nodejs = lang (g "e718");
  python = lang (g "e73c");
  java = lang (g "e738");
  kotlin = lang (g "e634");
  haskell = lang (g "e777");
  php = lang (g "e73d");
  docker_context = {
    symbol = g "f308";
    format = seg "info" "$symbol( $context)";
  };
  conda.format = seg "info" "$symbol( $environment)";

  cmd_duration = {
    min_time = 2000;
    format = "[${g "f252"} $duration  ](fg:text_dim)";
  };
  time = {
    disabled = false;
    time_format = "%R";
    format = "[$time](fg:text_dim)";
  };

  line_break.disabled = false;
  character = {
    success_symbol = "[❯](bold fg:accent)";
    error_symbol = "[❯](bold fg:err)";
    vimcmd_symbol = "[❮](bold fg:accent)";
    vimcmd_replace_one_symbol = "[❮](bold fg:warn)";
    vimcmd_replace_symbol = "[❮](bold fg:warn)";
    vimcmd_visual_symbol = "[❮](bold fg:info)";
  };
}
