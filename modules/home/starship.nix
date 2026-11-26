# Starship prompt: a row of filled blocks, each rounding into the next. Deep
# red for the machine, yellow for the directory, green for git, blue for
# tooling, in the terminal's own normal colours (p.gruvbox), with dark text.
# The clock and command duration sit dimmed in the right prompt, and the
# input line starts with a green ❯ that turns red after a failing command.
#
# Colours go through a starship palette rather than literal hex, so
# remote-theme.nix can recolour the prompt for SSH sessions by overriding
# `machine`, `accent` and `err`.
p:
let
  # Nerd Font glyphs by codepoint. They live in Unicode's private-use area,
  # which doesn't survive copy/paste reliably, and Nix strings have no \u
  # escape, so decode them from JSON instead.
  g = hex: builtins.fromJSON "\"\\u${hex}\"";
  capL = g "e0b6"; # left half-circle
  capR = g "e0b4"; # right half-circle, also the join between blocks

  # A block's text. An absent segment collapses to nothing, leaving only the
  # round joins either side of it, so the row still joins up.
  on = colour: body: "[${body}](fg:ink bg:${colour})";

  langGlyphs = {
    c = "e61e";
    rust = "e7a8";
    golang = "e627";
    nodejs = "e718";
    python = "e73c";
    java = "e738";
    kotlin = "e634";
    haskell = "e777";
    php = "e73d";
  };
  langs = builtins.mapAttrs (_: hex: {
    symbol = g hex;
    format = on "blue" " $symbol( $version)";
  }) langGlyphs;
in
{
  format = builtins.concatStringsSep "" [
    "[${capL}](fg:machine)"
    "$os"
    "$username"
    "$hostname"
    "[${capR}](fg:machine bg:yellow)"
    "$directory"
    "[${capR}](fg:yellow bg:green)"
    "$git_branch"
    "$git_state"
    "$git_status"
    "[${capR}](fg:green bg:blue)"
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
    "[${capR}](fg:blue)"
    "$line_break"
    "$character"
  ];
  right_format = "$cmd_duration$time";
  add_newline = true;

  palette = "gruvbox";
  palettes.gruvbox = {
    inherit (p.gruvbox) yellow green blue;
    machine = p.gruvbox.red;
    ink = p.gruvbox.background; # text on the blocks
    cream = p.gruvbox.foreground; # text on the machine block
    text_dim = p.gruvbox.white;
    # The ❯ is brighter than the blocks, to show against the dark background
    accent = "#b0b846";
    err = "#f2594b";
  };

  # The machine block is the one with cream text: a dark logo on red looks
  # like a hole in it. No padding after the logo, since the round join
  # already gives it room; the user and host bring their own.
  os = {
    disabled = false;
    format = "[$symbol](fg:cream bg:machine)";
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
    format = "[ $user](fg:cream bg:machine)";
  };
  hostname = {
    ssh_only = true;
    format = "[@$hostname](fg:cream bg:machine)";
  };

  directory = {
    format = "[ $path$read_only ](bold fg:ink bg:yellow)";
    read_only = " ${g "f023"}";
    truncation_length = 3;
    truncation_symbol = "…/";
  };

  git_branch = {
    symbol = g "f418";
    format = on "green" " $symbol $branch ";
  };
  git_state.format = on "green" "$state( $progress_current/$progress_total) ";
  git_status.format = "(${on "green" "$all_status$ahead_behind "})";

  # A small marker inside direnv / `nix develop` shells, detected through
  # IN_NIX_SHELL; the PATH heuristic misfires on NixOS, where /nix/store
  # paths are everywhere
  nix_shell = {
    symbol = g "f313";
    format = on "blue" " $symbol( $name)";
    heuristic = false;
  };
  docker_context = {
    symbol = g "f308";
    format = on "blue" " $symbol( $context)";
  };
  conda.format = on "blue" " $symbol( $environment)";

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
  # Blue and yellow in fish's vi normal and select modes, like helix's modes
  character = {
    success_symbol = "[❯](bold fg:accent)";
    error_symbol = "[❯](bold fg:err)";
    vimcmd_symbol = "[❮](bold fg:blue)";
    vimcmd_replace_one_symbol = "[❮](bold fg:err)";
    vimcmd_replace_symbol = "[❮](bold fg:err)";
    vimcmd_visual_symbol = "[❮](bold fg:yellow)";
  };
}
// langs
