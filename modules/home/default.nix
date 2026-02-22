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
    httpie
    delta
    procs
    nix-output-monitor
    tree
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
    kc = "kubectl";
    zj = "zellij";
    # nom wrappers
    nix-shell = "nom-shell";
    nix-build = "nom-build";
    nix-develop = "nom develop";
    # dev shortcuts
    tf = "terraform";
    yz = "yazi";
    lg = "lazygit";
    hxp = "hx ~/workspace/git/scratchpad/";
    # git shortcuts
    gs = "git status";
    glo = "git log --oneline --graph --all";
    gwc = "git-worktree-tmp";
    # WSL only alias
    sdown = "sudo /mnt/c/Windows/System32/shutdown.exe /s /f /t 0";
  } // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    pbcopy = "xclip -selection clipboard";
    pbpaste = "xclip -selection clipboard -o";
  };

  home.sessionVariables = {
    EDITOR = "hx";
    TERMINAL = "alacritty";
    NIXPKGS_ALLOW_UNFREE = 1;
  };

}
