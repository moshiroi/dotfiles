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
    interactiveShellInit = lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
      # Ensure Nix is loaded after OS upgrade
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      end
    '';
    shellInit = ''
      fish_add_path -a $HOME/.cargo/bin
    '';
    functions = {
      ship = ''
        git add .
        git commit -m $argv[1]
        git push
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
      default_shell = "fish";
    };
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    colors = {
      "bg+" = "#f2e5bc";
      "bg" = "#fbf1c7";
      "spinner" = "#d65d0e";
      "hl" = "#928374";
      "fg" = "#3c3836";
      "header" = "#928374";
      "info" = "#8ec07c";
      "pointer" = "#d65d0e";
      "marker" = "#d65d0e";
      "fg+" = "#3c3836";
      "prompt" = "#d65d0e";
      "hl+" = "#d65d0e";
    };
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
