final: prev: {
  claude-code = prev.claude-code.overrideAttrs (old: rec {
    version = "2.1.32";
    src = final.fetchurl {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
      hash = "sha256-qMCPsYVxWnn46Hah9Qd+rSN6eOQ/8Qafd35IfHkLAe0=";
    };
  });
}
