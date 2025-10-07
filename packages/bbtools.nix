{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  jre,
}:
stdenv.mkDerivation rec {
  pname = "bbtools";
  version = "39.36";

  src = fetchurl {
    url = "https://sourceforge.net/projects/bbmap/files/BBMap_${version}.tar.gz/download";
    name = "BBMap_${version}.tar.gz";
    sha256 = "sha256-9eh7QJ+lj+o1I0MXfSCMDANTbPlWnLgCpwBtt1Sm+Zs=";
  };

  nativeBuildInputs = [makeWrapper];
  buildInputs = [jre];

  sourceRoot = "bbmap";

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/bbmap
    mkdir -p $out/bin

    cp -r ./* $out/opt/bbmap

    chmod +x $out/opt/bbmap/*.sh

    for script in $out/opt/bbmap/*.sh; do
     if [ -f "$script" ]; then
        scriptName=$(basename "$script" .sh)
        makeWrapper "$script" "$out/bin/$scriptName" \
          --prefix PATH : ${lib.makeBinPath [jre]} \
          --set JAVA_HOME ${jre} \
          --chdir $out/opt/bbmap
      fi
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "BBTools suite for DNA/RNA sequence analysis";
    longDescription = ''
      BBTools is a suite of fast, multithreaded bioinformatics tools designed
      for analysis of DNA and RNA sequence data. It includes tools for read
      quality assessment, adapter trimming, contamination filtering, alignment,
      and various other sequence manipulation tasks.
    '';
    homepage = "https://jgi.doe.gov/data-and-tools/bbtools/";
    downloadPage = "https://sourceforge.net/projects/bbmap/";
    changelog = "https://sourceforge.net/projects/bbmap/files/";
    license = licenses.bsd3;
    platforms = platforms.unix;
    maintainers = [];
    mainProgram = "bbmap";
  };
}
