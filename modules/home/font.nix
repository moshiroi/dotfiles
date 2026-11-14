# One terminal font for everything. Terminals (ghostty, alacritty, rex) use
# all of it. The family defaults to the theme's mono font (modules/theme), so
# it is named in one place; desktop UI uses the theme's UI font instead. The
# font itself is installed system-wide in modules/common/system.nix
# (fonts.packages).
{ lib, ... }:
let
  theme = import ../theme { inherit lib; };
in
{
  options.dotfiles.terminalFont = {
    family = lib.mkOption {
      type = lib.types.str;
      default = theme.font.mono;
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
