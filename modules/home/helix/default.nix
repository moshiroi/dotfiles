{ pkgs, lib, ... }:
let
  custom-cat = import ./catppuccin.nix;

  # custom-cat with every hue at the same lightness but about 30% more
  # saturation (same OKLCH lightness and hue, chroma x1.3). The original's
  # calm comes from its colours all being equally bright, so this keeps that
  # and only makes them richer. This is the default theme; `:theme custom-cat`
  # switches back to the original.
  richer = {
    "#ea6962" = "#ff514f"; # red
    "#e78a4e" = "#f87e1d"; # orange
    "#d8a657" = "#e3a228"; # yellow
    "#a9b665" = "#a8b847"; # green
    "#89b482" = "#7fb876"; # aqua
    "#7daea3" = "#6fb1a3"; # blue
    "#d3869b" = "#e07c9a"; # pink
  };
  # Swaps colours wherever they are a plain value; a list of colours (a
  # `rainbow` key, say) would need handling here too.
  recolour = lib.mapAttrsRecursive (_: v: if builtins.isString v then richer.${v} or v else v);
in
{
  package = pkgs.helix;
  enable = true;
  defaultEditor = true;
  themes.alexis = import ./gruvbox.nix;
  themes.custom-cat = custom-cat;
  themes.custom-cat-plus = recolour custom-cat;
  languages = {
    language-server = {
      nixd = {
        command = "nixd";
        args = [ "--inlay-hints" ];
      };

      rust-analyzer = {
        config.check.command = "clippy";
        imports.group.enable = false;
        files.excludeDirs = [ ".direnv" ];
      };
      css = {
        command = "css-languageserver";
        args = [ "--stdio" ];
      };
      c  = {
        command = "clangd";
        args = [ "--compile-commands-dir=compile_commands_directory" ];
      };
      latex-lsp.command = "ltex-ls";
      typescript-language-server.config.documentFormatting = false;
      eslint = {
        command = "vscode-eslint-language-server";
        args = [ "--stdio" ];
        config = {
          validate = "on";
          experimental = { useFlatConfig = false; };
          rulesCustomizations = [ ];
          run = "onType";
          problems = { shortenToSingleLine = false; };
          nodePath = "";
          codeAction = {
            disableRuleComment = {
              enable = true;
              location = "separateLine";
            };
            showDocumentation.enable = true;
          };
          codeActionOnSave = {
            enable = true;
            mode = "fixAll";
          };
          workingDirectory.mode = "location";
        };
      };
    };
    language = [
      {
        name = "bash";
        auto-format = false;
        formatter = { command = "shfmt"; };
        language-servers = [ "bash-language-server" ];
      }
      {
        name = "nix";
        auto-format = false;
        formatter = { command = "nixfmt"; };
        language-servers = [ "nixd" ];
      }
      {
        name = "java";
        language-servers = [ "jdtls" ];
      }
      {
        name = "c";
        language-servers = [ "clangd" ];
      }
      {
        name = "markdown";
        language-servers = [ "latex-lsp" ];
        file-types = [ "md" "txt" ];
        scope = "text.markdown";
        roots = [ ];
      }
      {
        name = "css";
        language-servers = [ "css" ];
      }
      {
        name = "scss";
        language-servers = [ "css" ];
      }
      {
        name = "typescript";
        auto-format = true;
        language-servers = [
          {
            except-features = [ "format" ];
            name = "typescript-language-server";
          }
          "eslint"
        ];
        formatter = {
          command = "prettier";
          args = [ "--parser" "typescript" ];
        };
      }
    ];
  };
  settings = {
    theme = "custom-cat-plus";
    keys.normal = {
      ret= "goto_word";
    };
    editor = {
      rainbow-brackets = true;
      word-completion = {
        enable = true;
        trigger-length = 4;
      };
      indent-guides.render = true;
      true-color = true;
      line-number = "relative";
      soft-wrap.enable = true;
      bufferline = "multiple";
      color-modes = true;
      rulers = [
        100
        120
        150
      ];
      end-of-line-diagnostics = "hint";
      lsp = {
        display-inlay-hints = true;
        display-messages = true;
        auto-signature-help = false;
      };

      file-picker = { hidden = true; };
    };
  };
}
