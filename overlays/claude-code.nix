final: prev: {
  claude-code = final.stdenv.mkDerivation rec {
    pname = "claude-code";
    version = "2.1.53";

    src = final.fetchurl {
      url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/linux-x64/claude";
      hash = "sha256-3r8obypel0pQ8QKgNKLftd+M9KxU9/QTYmC1+QA4V1c=";
    };

    dontUnpack = true;
    dontStrip = true;
    dontPatchELF = true;

    nativeBuildInputs = [ final.makeWrapper ];

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/claude
      wrapProgram $out/bin/claude \
        --set DISABLE_AUTOUPDATER 1 \
        --unset DEV
      runHook postInstall
    '';

    meta = {
      description = "An agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster";
      homepage = "https://github.com/anthropics/claude-code";
      license = final.lib.licenses.unfree;
      mainProgram = "claude";
      platforms = [ "x86_64-linux" ];
    };
  };
}
