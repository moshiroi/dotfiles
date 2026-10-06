# Make remote sessions visually obvious. (Shared with nix-template, which has
# its own copy until it bumps its dotfiles pin.)
#
# - Locally: `ssh` / `coder ssh` tint the terminal background (alacritty and
#   ghostty both honour OSC 11) and reset it when the command exits. Works for
#   every host, including ones that don't run this config.
# - Remotely (machines running this config, e.g. coder): shells started over
#   ssh/coder get a red/purple starship palette and a different zellij theme.
{ config, lib, pkgs, ... }:
let
  remoteBg = "#3c1f1e";

  starship = config.programs.starship.settings;
  starshipRemote = (pkgs.formats.toml { }).generate "starship-remote.toml" (
    starship
    // {
      palette = "remote";
      palettes = starship.palettes // {
        remote = starship.palettes.${starship.palette} // {
          color_orange = "#cc241d";
          color_yellow = "#b16286";
        };
      };
    }
  );

  zellijRemote = pkgs.runCommandLocal "zellij-remote.kdl" { } ''
    sed 's/^theme .*/theme "tokyo-night"/' ${
      config.xdg.configFile."zellij/config.kdl".source
    } > $out
  '';
in
{
  # Ghostty's terminfo, so `clear`, htop etc. work when ghostty sshes into this
  # machine (TERM=xterm-ghostty). Linked into ~/.terminfo because that's the one
  # directory system ncurses (/usr/bin/clear on Ubuntu) always searches; the nix
  # profile's share/terminfo isn't on its path. Linux only: nixpkgs doesn't
  # build ghostty for macOS.
  home.file.".terminfo/x/xterm-ghostty" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    source = "${pkgs.ghostty.terminfo}/share/terminfo/x/xterm-ghostty";
  };

  programs.fish.interactiveShellInit = ''
    if set -q SSH_CONNECTION; or set -q CODER
      set -gx STARSHIP_CONFIG ${starshipRemote}
      set -gx ZELLIJ_CONFIG_FILE ${zellijRemote}
    else
      function __remote_bg_on --on-event fish_preexec
        if string match -qr '^\s*(ssh|coder ssh)\b' -- $argv[1]
          printf '\e]11;${remoteBg}\a'
          set -g __remote_bg 1
        end
      end
      function __remote_bg_off --on-event fish_postexec
        if set -q __remote_bg
          printf '\e]111\a'
          set -e __remote_bg
        end
      end
    end
  '';
}
