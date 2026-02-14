{ lib, pkgs, ... }: {
  imports = [
    ./programs.nix
  ];

  home.stateVersion = "22.11";
  nixpkgs.config.allowUnfree = true;
  home.packages = let
    git-worktree-tmp = pkgs.writeShellScriptBin "git-worktree-tmp"
      (builtins.readFile ../../scripts/git-worktree-tmp.sh);
  in with pkgs;
  [
    # Linters + formatting
    nufmt
    nixd
    nixfmt-classic
    vscode-langservers-extracted
    nodePackages.prettier
    nodePackages.typescript-language-server
    bash-language-server
    shfmt

    # Util
    openssh
    openssl
    qemu
    qemu_kvm
    just

    # Dev tooling
    claude-code
    ripgrep
    eza
    fd
    sd
    zellij
    yazi
    fzf
    zoxide
    httpie
    delta
    procs
    nix-output-monitor
    tree
    lazygit
    git-worktree-tmp

    # Python specific
    pyenv
    pipx
    (python3.withPackages
      (pyPkgs: with pyPkgs; [ python-lsp-server python-lsp-ruff ]))
    poetry
  ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ wl-clipboard-x11 ];

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
    sdown = "sudo /mnt/c/Windows/System32/shutdown.exe /s /f /t 0";
    hxp = "hx /git/plan";
  };

  home.sessionVariables = {
    EDITOR = "hx";
    TERMINAL = "alacritty";
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  programs.kitty.enable = true;

  xdg.configFile = lib.mkIf pkgs.stdenv.isLinux {
    "nushell/config.nu".source = ./nushell/config.nu;
    "nushell/zoxide.nu".source = ./nushell/zoxide.nu;
    "nushell/fzf.nu".source = ./nushell/fzf.nu;
    "nushell/env.nu".source = ./nushell/env.nu;
    "kitty/kitty.conf".source = ./kitty/kitty.conf;
    "kitty/theme.conf".source = ./kitty/theme.conf;
  };

  # Darwin doesnt respect xdg config dirs
  home.file = lib.mkIf pkgs.stdenv.isDarwin {
    "Library/Application Support/nushell/config.nu".source = ./nushell/config.nu;
    "Library/Application Support/nushell/zoxide.nu".source = ./nushell/zoxide.nu;
    "Library/Application Support/nushell/fzf.nu".source = ./nushell/fzf.nu;
    "Library/Application Support/nushell/env.nu".source = ./nushell/env.nu;
    ".config/kitty/kitty.conf".source = ./kitty/kitty.conf;
    ".config/kitty/theme.conf".source = ./kitty/theme.conf;
  };
}
