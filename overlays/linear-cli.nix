final: prev:
let
  version = "1.11.1";

  sources = {
    x86_64-linux = {
      url = "https://github.com/schpet/linear-cli/releases/download/v${version}/linear-x86_64-unknown-linux-gnu.tar.xz";
      hash = "sha256-S7zwxOYXwYmK+zcyuhuvVW8JhXPI5hgaWiyEz7T0gII=";
    };
    aarch64-linux = {
      url = "https://github.com/schpet/linear-cli/releases/download/v${version}/linear-aarch64-unknown-linux-gnu.tar.xz";
      hash = "sha256-LjVUdCvlcc8+mqfSpIB6L8u+oGPWu8BWx+VB0gHg4ZI=";
    };
    x86_64-darwin = {
      url = "https://github.com/schpet/linear-cli/releases/download/v${version}/linear-x86_64-apple-darwin.tar.xz";
      hash = "sha256-e8wVVPpWLwTUFc/Qr54Gf/w7MskCEovsRLVEh61t1Qk=";
    };
    aarch64-darwin = {
      url = "https://github.com/schpet/linear-cli/releases/download/v${version}/linear-aarch64-apple-darwin.tar.xz";
      hash = "sha256-v906DXJ3YgGLX9wnQ6yZN/1wiws99wxz2tas1idEdpQ=";
    };
  };

  src = sources.${final.stdenv.hostPlatform.system}
    or (throw "Unsupported system: ${final.stdenv.hostPlatform.system}");
in
{
  linear-cli = final.stdenv.mkDerivation {
    pname = "linear-cli";
    inherit version;

    src = final.fetchurl {
      inherit (src) url hash;
    };

    # Deno-compiled binaries store an embedded JS bundle as a trailer
    # appended after the ELF. patchelf and strip both modify the file
    # layout and break the trailer detection, so we must avoid them.
    dontStrip = true;
    dontPatchELF = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 linear $out/bin/linear
      runHook postInstall
    '';

    meta = {
      description = "CLI tool for managing Linear issues from the command line";
      homepage = "https://github.com/schpet/linear-cli";
      license = final.lib.licenses.isc;
      mainProgram = "linear";
      platforms = builtins.attrNames sources;
    };
  };
}
