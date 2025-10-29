{
  lib,
  pkgs,
  ...
}:
{

  home.stateVersion = "22.11"; # Adjust this version as needed
  nixpkgs.config.allowUnfree = true;
  home.packages =
    with pkgs;
    [
      # Infra
      awscli2
      kubectl
      terraform
      k9s
      flyctl

      # Linters + formatting
      nixd
      nixfmt
      vscode-langservers-extracted
      nodePackages.prettier
      nodePackages.typescript-language-server

      # Util
      openssh
      openssl
      protobuf
      ffmpeg
      google-chrome
      qemu
      qemu_kvm
      just

      # Dev tooling
      nushell
      kitty
      ripgrep
      eza
      fd
      sd
      zellij
      yazi
      fzf
      httpie
      delta
      procs
      nix-output-monitor

      # Python specific
      pyenv
      pipx
      (python3.withPackages (
        pyPkgs: with pyPkgs; [
          # python-lsp-server
          # python-lsp-ruff
        ]
      ))
      poetry
    ];

  fonts.fontconfig.enable = true;
  home.shellAliases = {
    htop = "btm";
    top = "btm";
    cat = "bat";
    ls = "eza";
    tf = "terraform";
    kc = "kubectl";
    ship = "git add .; git commit -m 'ship'; git push";
    zj = "zellij";
    # WSL only alias
    # TODO: Take WSL as a bool specialArg
    sdown = "sudo /mnt/c/Windows/System32/shutdown.exe /s /f /t 0";
    hxp = "hx /git/plan";
  };

  home.sessionVariables = {
    EDITOR = "hx";
    TERMINAL = "alacritty";
  };

  programs.git = {
    enable = true;
    aliases = {
      s = "status";
    };
    userName = "moshiroi";
    userEmail = "mqsas1337@gmail.com";
    lfs.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
    };
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

  # TODO: Add nushell equivalent for fzf keybindings
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    initExtra =
      let

        darwinSpecific = lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
          # Ensure Nix is loaded after OS upgrade
          if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
            . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
          fi
        '';

      in
      ''
        export PATH="$PATH:$HOME/.cargo/bin"

        if [ -n "''${commands[fzf-share]}" ]; then
          source "$(fzf-share)/key-bindings.zsh"
          source "$(fzf-share)/completion.zsh"
        fi
      ''
      + darwinSpecific;
  };

  programs.helix = import ./helix.nix { helix-master = pkgs.helix; };

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal.family = "IosevkaTerm Nerd Font";
        normal.style = "Medium";
        size = 10.0;
      };
      window.option_as_alt = "OnlyLeft";
    };
  };

  programs.starship =
    let
      starship_gruvbox = builtins.fromTOML (builtins.readFile ./starship-gruvbox.toml);
    in
    {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      settings = {
        format = "$all";
        palette = "gruvbox_rainbow";
        shell.program = "nushell";
      }
      // starship_gruvbox;
    };

  programs.zellij = {
    enable = true;
    enableZshIntegration = false;
    settings = {
      show_startup_tips = false;
      theme = "gruvbox-dark";
      # ui.pane_frames.hide_session_name = true;
      pane_frames = false;
      default_shell = "nu";
    };
  };

  programs.fzf = {
    enable = true;
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

  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
    nix-direnv.enable = true;
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
  
  programs.bottom.enable = true;
  programs.bat.enable = true;

  programs.kitty.enable = true;
  xdg.configFile."kitty/kitty.conf".source = ./kitty/kitty.conf;
  xdg.configFile."kitty/theme.conf".source = ./kitty/theme.conf;

  xdg.configFile."nushell/config.nu".source = ./nu/config.nu;
  xdg.configFile."nushell/env.nu".source = ./nu/env.nu;
  xdg.configFile."nushell/fzf.nu".source = ./nu/fzf.nu;
}
