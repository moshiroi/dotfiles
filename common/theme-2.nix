# Catppuccin Mocha theme configuration for helix
let
  # Catppuccin Mocha color palette
  rosewater = "#ea6962";
  flamingo = "#ea6962";
  red = "#ea6962";
  maroon = "#ea6962";
  pink = "#d3869b";
  mauve = "#d3869b";
  peach = "#e78a4e";
  yellow = "#d8a657";
  green = "#a9b665";
  teal = "#89b482";
  sky = "#89b482";
  sapphire = "#89b482";
  blue = "#7daea3";
  lavender = "#7daea3";
  text = "#ebdbb2";
  subtext1 = "#d5c4a1";
  subtext0 = "#bdae93";
  overlay2 = "#a89984";
  overlay1 = "#928374";
  overlay0 = "#595959";
  surface2 = "#4d4d4d";
  surface1 = "#404040";
  surface0 = "#292929";
  base = "#1d2021";
  mantle = "#191b1c";
  crust = "#141617";

  # Diagnostic colors
  error = {
    bg = maroon;
    fg = red;
  };
  hint = {
    bg = surface1;
    fg = sapphire;
  };
  info = {
    bg = surface1;
    fg = sky;
  };
  warning = {
    bg = surface1;
    fg = peach;
  };
  unnecessary = { modifiers = [ "dim" ]; };
  deprecated = { modifiers = [ "crossed_out" ]; };

  default = {
    fg = text;
    bg = base;
  };

  cursor = lavender;
  cursor_match = flamingo;

  cursorline_primary = surface0;
  cursorline_secondary = mantle;

  help = surface1;

  linenr = overlay1;
  selected = {
    fg = yellow;
    bg = surface0;
  };

  popup = surface1;

  selection_secondary = surface0;
  selection_primary = surface1;

  statusline = surface1;
  statusline_inactive = {
    fg = subtext1;
    bg = crust;
  };

  mode = { bg = surface2; };
  mode_insert = green;
  mode_normal = lavender;
  mode_select = yellow;

  text_inactive = subtext1;

  indent_guide = overlay0;
  whitespace = surface0;

  inlay_hint = {
    fg = overlay2;
    bg = mantle;
  };

  inline_diagnostics = { bg = mantle; };

  # Markup
  heading = red;
  markup_raw = peach;

  # Language
  attribute = peach;
  comment = overlay2;
  comment_doc = rosewater;
  constant = flamingo;
  diff_delta = yellow;
  diff_minus = maroon;
  diff_moved = pink;
  diff_plus = green;
  field = sky;
  function = blue;
  keyword = red;
  kw_return = mauve;
  label = sapphire;
  link_text = blue;
  link_url = lavender;
  macro = teal;
  markup_list = mauve;
  markup_quote = green;
  namespace = yellow;
  operator = sky;
  special = rosewater;
  string = green;
  type = yellow;

  # Placeholder for testing
  placeholder = {
    fg = pink;
    bg = surface2;
  };

  mod_bold = { modifiers = [ "bold" ]; };
  mod_underline = { underline = { style = "line"; }; };

in {
  "diagnostic.error" = {
    underline.color = error.fg;
  } // mod_underline // mod_bold;
  "diagnostic.hint" = {
    underline.color = hint.fg;
  } // mod_underline // mod_bold;
  "diagnostic.info" = {
    underline.color = info.fg;
  } // mod_underline // mod_bold;
  "diagnostic.warning" = {
    underline.color = warning.fg;
  } // mod_underline // mod_bold;
  "diagnostic.unnecessary" = unnecessary;
  "diagnostic.deprecated" = deprecated;
  "error" = {
    fg = error.fg;
    bg = inline_diagnostics.bg;
  };
  "hint" = {
    fg = hint.fg;
    bg = inline_diagnostics.bg;
  };
  "info" = {
    fg = info.fg;
    bg = inline_diagnostics.bg;
  };
  "warning" = {
    fg = warning.fg;
    bg = inline_diagnostics.bg;
  };
  "ui" = {
    fg = text;
    bg = default.bg;
  };
  "ui.background" = { bg = default.bg; };
  "ui.bufferline" = {
    fg = text;
    bg = statusline_inactive.bg;
  };
  "ui.bufferline.active" = {
    fg = text;
    bg = statusline;
  } // mod_bold;
  "ui.bufferline.background" = { bg = default.bg; };
  "ui.cursor" = { bg = cursor; };
  "ui.cursor.match" = { bg = cursor_match; };
  "ui.cursor.primary" = { modifiers = [ "reversed" ]; };
  "ui.cursorline.primary" = { bg = cursorline_primary; };
  "ui.cursorline.secondary" = { bg = cursorline_secondary; };
  "ui.gutter.selected" = { bg = selected.bg; };
  "ui.help" = { bg = help; };
  "ui.highlight" = { bg = cursorline_primary; };
  "ui.linenr" = linenr;
  "ui.linenr.selected" = selected;
  "ui.menu" = {
    fg = text;
    bg = popup;
  };
  "ui.menu.scroll" = {
    fg = text;
    bg = popup;
  };
  "ui.menu.selected" = selected;
  "ui.picker.header.column" = { fg = text; } // mod_underline;
  "ui.picker.header.column.active" = { fg = selected.fg; } // mod_underline;
  "ui.popup" = {
    fg = text;
    bg = popup;
  };
  "ui.selection" = { bg = selection_secondary; };
  "ui.selection.primary" = { bg = selection_primary; };
  "ui.statusline" = {
    fg = text;
    bg = statusline;
  };
  "ui.statusline.inactive" = statusline_inactive;
  "ui.statusline.insert" = {
    fg = mode_insert;
    bg = mode.bg;
  } // mod_bold;
  "ui.statusline.normal" = {
    fg = mode_normal;
    bg = mode.bg;
  } // mod_bold;
  "ui.statusline.select" = {
    fg = mode_select;
    bg = mode.bg;
  } // mod_bold;
  "ui.statusline.separator" = text;
  "ui.text" = text;
  "ui.text.directory" = special;
  "ui.text.focus" = selected;
  "ui.text.inactive" = text_inactive;
  "ui.text.info" = text;
  "ui.virtual" = { bg = inline_diagnostics.bg; };
  "ui.virtual.indent-guide" = indent_guide;
  "ui.virtual.inlay-hint" = inlay_hint;
  "ui.virtual.jump-label" = {
    fg = mode_normal;
    bg = statusline;
  } // mod_bold;
  "ui.virtual.ruler" = { bg = cursorline_primary; };
  "ui.virtual.whitespace" = whitespace;
  "ui.virtual.wrap" = inlay_hint;
  "ui.window" = text;

  # Mixed Keys (UI & languages)

  "markup" = text;
  "markup.heading" = { fg = heading; } // mod_bold;
  "markup.raw" = markup_raw;
  "markup.raw.inline" = markup_raw;

  # Language-only Keys

  "attribute" = attribute;
  "boolean" = { fg = constant; } // mod_bold;
  "clean" = keyword;
  "comment" = comment;
  "comment.block.documentation" = comment_doc;
  "comment.documentation" = comment_doc;
  "constant" = constant;
  "constant.builtin.boolean" = { fg = constant; } // mod_bold;
  "constant.character.escape" = { fg = text; } // mod_bold;
  "constructor" = macro;
  "diff.delta" = diff_delta;
  "diff.delta.moved" = diff_moved;
  "diff.minus" = diff_minus;
  "diff.plus" = diff_plus;
  "embedded" = keyword;
  "exception" = { fg = keyword; } // mod_underline;
  "field" = field;
  "file" = { fg = string; } // mod_underline;
  "function" = function;
  "function.macro" = macro;
  "identifier" = text;
  "include" = keyword;
  "keyword" = keyword;
  "keyword.control.exception" = kw_return;
  "keyword.control.return" = kw_return;
  "keyword.directive" = attribute;
  "keyword.special" = special;
  "keyword.storage.modifier.mut" = { fg = keyword; } // mod_underline;
  "label" = label;
  "markup.bold" = mod_bold;
  "markup.inline" = markup_raw;
  "markup.italic" = { modifiers = [ "italic" ]; };
  "markup.label" = label;
  "markup.link.label" = label;
  "markup.link.text" = link_text;
  "markup.link.uri" = link_url;
  "markup.link.url" = link_url;
  "markup.list" = markup_list;
  "markup.quote" = markup_quote;
  "markup.raw.block" = markup_raw;
  "markup.strikethrough" = { modifiers = [ "crossed_out" ]; };
  "markup.underlined" = mod_underline;
  "namespace" = namespace;
  "none" = text;
  "number" = constant;
  "operator" = operator;
  "parameter" = text;
  "punctuation" = attribute;
  "punctuation.special" = { fg = attribute; } // mod_bold;
  "special" = { fg = special; } // mod_bold;
  "string" = string;
  "string.escape" = { fg = text; } // mod_bold;
  "string.regexp" = { fg = text; } // mod_bold;
  "string.special" = { fg = special; } // mod_underline;
  "string.special.path" = special;
  "symbol" = { bg = placeholder.bg; };
  "tag" = keyword;
  "tag.error" = error.fg;
  "text" = text;
  "time" = { modifiers = [ "italic" ]; };
  "type" = type;
  "variable" = text;
  "variable.builtin" = keyword;
  "variable.other.member" = field;
}
