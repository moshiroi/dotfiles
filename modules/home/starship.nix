# Starship prompt in Lichen (./palette.nix): one rounded pill on a subtle
# surface, the same capsule language as the Noctalia bar. The text carries
# the information, not filled blocks: directory in bold bone, git branch in
# sage, changes in amber, toolchains in teal, with hairline dividers. The
# clock and command duration sit dimmed in the right prompt, and the input
# line starts with a sage ❯ that turns red after a failing command.
#
# Colours go through a starship palette rather than literal hex, so
# remote-theme.nix can recolour the prompt for SSH sessions by overriding
# `surface`, `accent` and `err`.
#
# With `vivid` (the Mac, whose terminal runs saturated Gruvbox, see ./rex)
# the pill becomes a row of filled blocks instead: `blocks` below overrides
# the formats and the palette, and everything else is shared.
{ p, vivid ? false }:
let
  # Nerd Font glyphs by codepoint. They live in Unicode's private-use area,
  # which doesn't survive copy/paste reliably, and Nix strings have no \u
  # escape, so decode them from JSON instead.
  g = hex: builtins.fromJSON "\"\\u${hex}\"";
  capL = g "e0b6"; # left half-circle
  capR = g "e0b4"; # right half-circle

  # The modules in prompt order, grouped the way both layouts group them
  machine = [ "$os" "$username" "$hostname" ];
  git = [ "$git_branch" "$git_state" "$git_status" ];
  tooling = [
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
  ];
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
  # Every language module, with its symbol and version wrapped by `wrap`
  langs = wrap: builtins.mapAttrs (_: hex: {
    symbol = g hex;
    format = wrap "$symbol( $version)";
  }) langGlyphs;

  # One segment inside the pill, preceded by a hairline divider. The divider
  # lives inside the segment's format, so it disappears when the segment does.
  seg = colour: body:
    "[ │ ](fg:divider bg:surface)[${body}](fg:${colour} bg:surface)";

  base = {
    format = builtins.concatStringsSep "" (
      [ "[${capL}](fg:surface)" ]
      ++ machine
      ++ [ "$directory" ]
      ++ git
      ++ tooling
      ++ [
        "[ ](bg:surface)[${capR}](fg:surface)"
        "$line_break"
        "$character"
      ]
    );
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
  } // langs (seg "info");

  # The vivid variant: filled blocks, each rounding into the next. Deep red
  # for the machine, yellow for the directory, green for git, blue for
  # tooling, in the terminal's own normal colours (p.gruvbox), with dark text.
  # The ❯ stays bright so it shows against the dark background, and takes
  # blue and yellow in fish's vi normal and select modes, like helix's modes.
  #
  # A block's text. An absent segment collapses to nothing, leaving only the
  # round joins either side of it, so the row still joins up.
  on = colour: body: "[${body}](fg:ink bg:${colour})";
  blocks = {
    format = builtins.concatStringsSep "" (
      [ "[${capL}](fg:machine)" ]
      ++ machine
      ++ [ "[${capR}](fg:machine bg:yellow)" "$directory" "[${capR}](fg:yellow bg:green)" ]
      ++ git
      ++ [ "[${capR}](fg:green bg:blue)" ]
      ++ tooling
      ++ [
        "[${capR}](fg:blue)"
        "$line_break"
        "$character"
      ]
    );
    palette = "gruvbox";
    palettes.gruvbox = {
      inherit (p.gruvbox) yellow green blue;
      machine = p.gruvbox.red;
      ink = p.gruvbox.background; # text on the blocks
      cream = p.gruvbox.foreground; # text on the machine block
      text_dim = p.gruvbox.white;
      accent = "#b0b846";
      err = "#f2594b";
    };

    # The machine block is the one with cream text: a dark logo on red looks
    # like a hole in it. No padding after the logo, since the round join
    # already gives it room; the user and host (SSH only) bring their own.
    os = base.os // { format = "[$symbol](fg:cream bg:machine)"; };
    username = base.username // { format = "[ $user](fg:cream bg:machine)"; };
    hostname = base.hostname // { format = "[@$hostname](fg:cream bg:machine)"; };
    directory = base.directory // {
      format = "[ $path$read_only ](bold fg:ink bg:yellow)";
    };
    git_branch = base.git_branch // { format = on "green" " $symbol $branch "; };
    git_state.format = on "green" "$state( $progress_current/$progress_total) ";
    git_status.format = "(${on "green" "$all_status$ahead_behind "})";
    nix_shell = base.nix_shell // { format = on "blue" " $symbol( $name)"; };
    docker_context = base.docker_context // { format = on "blue" " $symbol( $context)"; };
    conda.format = on "blue" " $symbol( $environment)";

    character = base.character // {
      vimcmd_symbol = "[❮](bold fg:blue)";
      vimcmd_replace_one_symbol = "[❮](bold fg:err)";
      vimcmd_replace_symbol = "[❮](bold fg:err)";
      vimcmd_visual_symbol = "[❮](bold fg:yellow)";
    };
  } // langs (body: on "blue" " ${body}");
in
if vivid then base // blocks else base
