# config.nu
#
# Installed by:
# version = "0.104.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.
#
# 

alias nix-shell = nom-shell
alias nix-build = nom-build
alias nix-develop = nom develop

alias fg = job unfreeze

alias htop = btm;
alias top = btm;
alias cat = bat;
alias tf = terraform;
alias kc = kubectl;
alias zj = zellij;
alias hxp = hx ~/git/scratchpad/;

def ship [message: string] {
    git add .
    git commit -m $message
    git push
}

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
source ./fzf.nu
