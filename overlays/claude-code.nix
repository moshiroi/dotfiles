final: prev: {
  claude-code = prev.claude-code.overrideAttrs (old: rec {
    version = "2.1.45";
    src = final.fetchurl {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
      hash = "sha256-dhQKGZOyceItuwJbmy6JgrxackGGG1sZKsh/eeviIdk=";
    };
  });
}
