{ config, lib, pkgs, ... }:
let
  font = config.dotfiles.terminalFont;
  # Lichen, the desktop palette (modules/theme); the terminal uses its
  # surfaces with Gruvbox Material hues
  p = (import ../theme { inherit lib; }).palette;
in
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      alias = { s = "status"; };
      user.name = "moshiroi";
      user.email = "mqsas1337@gmail.com";
      init.defaultBranch = "main";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      light = false;
      line-numbers = true;
      side-by-side = true;
    };
  };

  programs.fish = {
    enable = true;
    plugins = [
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
    ];
    interactiveShellInit = ''
      ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        # Ensure Nix is loaded after OS upgrade
        if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
          source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        end
      ''}
      # Rebind fzf.fish process search: Ctrl+Alt+P is swallowed by the
      # compositor/terminal, so we use Ctrl+Alt+X instead.
      fzf_configure_bindings --processes=\e\cx
    '';
    shellInit = ''
      fish_add_path -a $HOME/.cargo/bin
      # Out-of-band installs (claude-code's self-updating native installer,
      # pipx, cargo-installed shims). Prepended so a self-updating tool wins
      # over a stale copy in the nix profile.
      fish_add_path -p $HOME/.local/bin
    '';
    functions = {
      # Silence the "Welcome to fish… type help" banner on every new shell.
      fish_greeting = "";
      ship = ''
        git add .
        git commit -m $argv[1]
        git push
      '';
      rv = ''
        direnv exec ~/workspace/git/rv cargo run --manifest-path ~/workspace/git/rv/Cargo.toml --quiet -- $argv
      '';
    };
  };

  programs.helix = import ./helix { inherit pkgs; };

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal.family = font.family;
        normal.style = font.style;
        size = font.size * 1.0; # alacritty wants a float
      };
      window.option_as_alt = "OnlyLeft";
    };
  };

  # Default terminal (replacing alacritty, which stays installed as a fallback).
  programs.ghostty = {
    enable = true;
    # nixpkgs only builds ghostty for Linux; on macOS install Ghostty.app
    # separately and let home-manager just manage the config.
    package = if pkgs.stdenv.hostPlatform.isDarwin then null else pkgs.ghostty;
    enableFishIntegration = true;
    settings = {
      # Lichen surfaces and text with Gruvbox Material hues: Gruvbox's
      # colours in the same slots, desaturated, so code reads as before
      # without glaring in a dim room. Normal and bright share hues, as in
      # Gruvbox Material; bright black is lifted for comments.
      background = p.term.background;
      foreground = p.term.foreground;
      cursor-color = p.text;
      cursor-text = p.window;
      selection-background = p.term.selection;
      selection-foreground = p.text;
      palette = let t = p.term; in [
        "0=${t.black}" "1=${t.red}" "2=${t.green}" "3=${t.yellow}"
        "4=${t.blue}" "5=${t.magenta}" "6=${t.cyan}" "7=${t.white}"
        "8=${t.brightBlack}" "9=${t.red}" "10=${t.green}" "11=${t.yellow}"
        "12=${t.blue}" "13=${t.magenta}" "14=${t.cyan}" "15=${t.brightWhite}"
      ];
      font-family = font.family;
      font-style = font.style;
      font-size = font.size;
      # 15% more leading than the font's default, so dense output (diffs,
      # logs) has room to breathe without shrinking the type.
      adjust-cell-height = "15%";
      # Even margins on all sides instead of text touching the window edge;
      # balance centres the cell grid so leftover pixels split evenly, and
      # extend paints the padding with the cell background (no seams).
      window-padding-x = 14;
      window-padding-y = 10;
      window-padding-balance = true;
      window-padding-color = "extend";
      # Slightly translucent, blurred behind by niri (see the ghostty window
      # rule in desktop/niri.nix) and by Ghostty itself on macOS.
      background-opacity = 0.94;
      background-blur = true;
      # Thin bar cursor at the prompt (helix still sets its own per mode),
      # and dim unfocused splits so the active one stands out
      cursor-style = "bar";
      unfocused-split-opacity = 0.85;
      confirm-close-surface = false;
      macos-option-as-alt = "left";
      # Ghostty maps alt+arrows to esc:b / esc:f (word jumps), which zellij
      # reads as Alt+f (ToggleFloatingPanes). Unbind so zellij gets real arrows.
      # Its default ctrl+enter=toggle_fullscreen also swallows the key before
      # TUIs see it (Claude Code submits on ctrl+enter); niri covers fullscreen.
      keybind = [
        "alt+arrow_left=unbind"
        "alt+arrow_right=unbind"
        "ctrl+enter=unbind"
      ];
    } // lib.optionalAttrs (pkgs.stdenv.hostPlatform.isDarwin
      || lib.versionAtLeast pkgs.ghostty.version "1.2") {
      # Fall back to TERM=xterm-256color on hosts without ghostty's terminfo
      # (option added in ghostty 1.2; the macOS app is always current).
      shell-integration-features = "ssh-env";
    } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      # niri tiles and moves windows itself; keep native title bar on macOS.
      window-decoration = false;
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = false;
    enableNushellIntegration = false;
    enableFishIntegration = true;
    settings = import ./starship.nix p;
  };

  programs.zellij = {
    enable = true;
    enableZshIntegration = false;
    settings = {
      show_startup_tips = false;
      # Lichen, so the tab/status bar matches the desktop: sage marks the
      # active tab and mode; remote-theme.nix still swaps this line for SSH
      theme = "lichen";
      themes.lichen = {
        fg = p.text;
        bg = p.raised;
        black = p.window;
        red = p.error;
        green = p.accent;
        yellow = p.warning;
        blue = p.term.blue;
        magenta = p.term.magenta;
        cyan = p.term.cyan;
        white = p.text;
        orange = p.warning;
      };
      pane_frames = false;
      # zellij 0.45 replaced the one-line-per-pane stack with a title list at
      # the top; keep the old look.
      stacked_pane_list = false;
      default_shell = "fish";
      keybinds = {
        normal = {
          _children = [
            { bind = { _args = ["F1"]; NewTab = {}; }; }
            { bind = { _args = ["F2"]; NewPane = { _args = ["stacked"]; }; }; }
            { bind = { _args = ["F3"]; NewPane = { _args = ["Right"]; }; }; }
            { bind = { _args = ["F4"]; ToggleFocusFullscreen = {}; }; }
            { bind = { _args = ["F11"]; CloseFocus = {}; }; }
            { bind = { _args = ["F12"]; CloseTab = {}; }; }
          ];
        };
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = false; # handled by fzf.fish plugin
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = false;
    enableNushellIntegration = false;
    enableFishIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };

  programs.lazygit = {
    enable = true;
    settings.git.paging = {
      colorArg = "always";
      pager = "delta --paging=never --no-gitconfig --line-numbers";
    };
  };

  programs.bottom.enable = true;
  programs.bat.enable = true;
}
