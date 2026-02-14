# Source: https://github.com/junegunn/fzf/issues/4122
# Dependencies: `fd`, `bat, `rg`, `nufmt`, `tree`.
export-env {
  $env.FZF_ALT_C_COMMAND = "fd --type directory --hidden"
  $env.FZF_ALT_C_OPTS = "--preview 'tree -C {} | head -n 200'"
  $env.FZF_CTRL_T_COMMAND = "fd --type file --hidden"
  $env.FZF_CTRL_T_OPTS = "--preview 'bat --color=always --style=full --line-range=:500 {}' "
  $env.FZF_DEFAULT_COMMAND = "fd --type file --hidden"
}

# Directories
const alt_c = {
    name: fzf_dirs
    modifier: alt
    keycode: char_c
    mode: [emacs, vi_normal, vi_insert]
    event: [
      {
        send: executehostcommand
        cmd: "
          let fzf_alt_c_command = \$\"($env.FZF_ALT_C_COMMAND) | fzf ($env.FZF_ALT_C_OPTS)\";
          let result = nu -c $fzf_alt_c_command;
          cd $result;
        "
      }
    ]
}

# History
const ctrl_r = {
  name: history_menu
  modifier: control
  keycode: char_r
  mode: [emacs, vi_insert, vi_normal]
  event: [
    {
      send: executehostcommand
      cmd: "
        let result = history
          | reverse
          | get command
          | str replace --all (char newline) ' '
          | to text
          | fzf --height 40% --reverse --border --no-sort;
        commandline edit --append $result;
        commandline set-cursor --end
      "
    }
  ]
}

# Files
const ctrl_t =  {
    name: fzf_files
    modifier: control
    keycode: char_t
    mode: [emacs, vi_normal, vi_insert]
    event: [
      {
        send: executehostcommand
        cmd: "
          let fzf_ctrl_t_command = \$\"($env.FZF_CTRL_T_COMMAND) | fzf ($env.FZF_CTRL_T_OPTS)\";
          let result = nu -l -i -c $fzf_ctrl_t_command;
          commandline edit --append $result;
          commandline set-cursor --end
        "
      }
    ]
}

# Update the $env.config
export-env {
  # Gruvbox light theming
  $env.FZF_DEFAULT_OPTS = "--color " + ([
    "bg:#fbf1c7,bg+:#f2e5bc,fg:#3c3836,fg+:#3c3836"
    "header:#928374,hl:#928374,hl+:#d65d0e"
    "info:#8ec07c,marker:#d65d0e,pointer:#d65d0e"
    "prompt:#d65d0e,spinner:#d65d0e"
  ] | str join ",")

  # Only append if not already present (check by name)
  let has_history_menu = $env.config.keybindings | any {|kb| $kb.name == "history_menu"}

  if not $has_history_menu {
    $env.config.keybindings = $env.config.keybindings | append [
      $alt_c
      $ctrl_r
      $ctrl_t
    ]
  }
}
