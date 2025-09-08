{ helix-master }:
{
    package = helix-master;
    enable = true;
    defaultEditor = true;
    themes.alexis = import ./theme.nix;
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
      theme = "gruvbox_material_dark_hard";
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

        inline-diagnostics = {
          cursor-line = "error";
        };

        file-picker = { hidden = true; };
      };
    };
}
