{
  lib,
  stdenv,
  fetchurl,
  writeShellScriptBin,
  jre,
}: let
  bbtools-unwrapped = stdenv.mkDerivation rec {
    pname = "bbtools-unwrapped";
    version = "39.36";

    src = fetchurl {
      url = "https://sourceforge.net/projects/bbmap/files/BBMap_${version}.tar.gz/download";
      name = "BBMap_${version}.tar.gz";
      sha256 = "sha256-9eh7QJ+lj+o1I0MXfSCMDANTbPlWnLgCpwBtt1Sm+Zs=";
    };

    sourceRoot = "bbmap";
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/opt/bbmap
      cp -r ./* $out/opt/bbmap
      chmod +x $out/opt/bbmap/*.sh
      runHook postInstall
    '';
  };

  # Wrapper 스크립트
  bbtools-wrapper = writeShellScriptBin "bbtools" ''
    set -e

    BBTOOLS_DIR="${bbtools-unwrapped}/opt/bbmap"
    export PATH="${jre}/bin:$PATH"
    export JAVA_HOME="${jre}"

    if [ $# -eq 0 ]; then
      echo "Usage: bbtools <command> [args...]"
      echo ""
      echo "Available commands:"
      ls -1 "$BBTOOLS_DIR"/*.sh | xargs -n1 basename | sed 's/\.sh$//' | sort | column
      exit 1
    fi

    COMMAND="$1"
    shift

    SCRIPT="$BBTOOLS_DIR/$COMMAND.sh"

    if [ ! -f "$SCRIPT" ]; then
      echo "Error: Command '$COMMAND' not found" >&2
      echo "Run 'bbtools' without arguments to see available commands" >&2
      exit 1
    fi

    cd "$BBTOOLS_DIR"
    exec "$SCRIPT" "$@"
  '';
in
  bbtools-wrapper.overrideAttrs (old: {
    pname = "bbtools";
    version = "39.36";

    meta = with lib; {
      description = "BBTools suite for DNA/RNA sequence analysis";
      longDescription = ''
        BBTools is a suite of fast, multithreaded bioinformatics tools designed
        for analysis of DNA and RNA sequence data. It includes tools for read
        quality assessment, adapter trimming, contamination filtering, alignment,
        and various other sequence manipulation tasks.

        Usage: bbtools <command> [args...]
        Example: bbtools bbduk in=reads.fq out=clean.fq
      '';
      homepage = "https://jgi.doe.gov/data-and-tools/bbtools/";
      downloadPage = "https://sourceforge.net/projects/bbmap/";
      changelog = "https://sourceforge.net/projects/bbmap/files/";
      license = licenses.bsd3;
      platforms = platforms.unix;
      maintainers = [];
      mainProgram = "bbtools";
    };
  })
