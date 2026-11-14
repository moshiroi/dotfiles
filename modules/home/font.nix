# One terminal font for everything. Terminals (ghostty, alacritty, rex) use
# all of it; desktop bits (fuzzel, waybar, swaylock) use the family and keep
# their own sizes. The font itself is installed system-wide in
# modules/common/system.nix (fonts.packages).
{ lib, ... }:
{
  options.dotfiles.terminalFont = {
    family = lib.mkOption {
      type = lib.types.str;
      default = "JetBrainsMono Nerd Font";
    };
    style = lib.mkOption {
      type = lib.types.str;
      default = "Medium";
    };
    size = lib.mkOption {
      type = lib.types.int;
      default = 10;
      description = "Point size in terminals.";
    };
  };
}
