{ lib, pkgs, ... }:
{
  programs.git = {
    enable = true;
    aliases = { s = "status"; };
    userName = "moshiroi";
    userEmail = "mqsas1337@gmail.com";
    lfs.enable = true;
    extraConfig = { init.defaultBranch = "main"; };
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        line-numbers = true;
        side-by-side = true;
      };
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
        normal.family = "JetBrainsMono Nerd Font";
        normal.style = "Medium";
        size = 10.0;
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
      # Gruvbox Dark, inlined because the bundled theme name differs between
      # ghostty releases ("GruvboxDark" vs "Gruvbox Dark").
      background = "#282828";
      foreground = "#ebdbb2";
      cursor-color = "#ebdbb2";
      cursor-text = "#282828";
      selection-background = "#665c54";
      selection-foreground = "#ebdbb2";
      palette = [
        "0=#282828" "1=#cc241d" "2=#98971a" "3=#d79921"
        "4=#458588" "5=#b16286" "6=#689d6a" "7=#a89984"
        "8=#928374" "9=#fb4934" "10=#b8bb26" "11=#fabd2f"
        "12=#83a598" "13=#d3869b" "14=#8ec07c" "15=#ebdbb2"
      ];
      font-family = "JetBrainsMono Nerd Font";
      font-style = "Medium";
      font-size = 10;
      window-decoration = false;
      confirm-close-surface = false;
      macos-option-as-alt = "left";
    } // lib.optionalAttrs (pkgs.stdenv.hostPlatform.isDarwin
      || lib.versionAtLeast pkgs.ghostty.version "1.2") {
      # Fall back to TERM=xterm-256color on hosts without ghostty's terminfo
      # (option added in ghostty 1.2; the macOS app is always current).
      shell-integration-features = "ssh-env";
    };
  };

  programs.starship = let
    starship_gruvbox =
      builtins.fromTOML (builtins.readFile ./starship-gruvbox.toml);
  in {
    enable = true;
    enableZshIntegration = false;
    enableNushellIntegration = false;
    enableFishIntegration = true;
    settings = {
      format = "$all";
      palette = "gruvbox_rainbow";
    } // starship_gruvbox;
  };

  programs.zellij = {
    enable = true;
    enableZshIntegration = false;
    settings = {
      show_startup_tips = false;
      theme = "gruvbox-dark";
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
