{
  lib,
  stdenv,
  fetchurl,
  unzip,
  makeWrapper,
  jdk,
}:
stdenv.mkDerivation rec {
  pname = "aptasuite";
  version = "0.9.8";

  src = fetchurl {
    url = "https://github.com/drivenbyentropy/aptasuite/releases/download/v${version}/aptasuite-${version}.zip";
    sha256 = "sha256-qpQPI50Z98gDkkpFAI8/qlk2r47zkZMNLmrTyi8nq5A=";
  };

  nativeBuildInputs = [unzip makeWrapper];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    cd aptasuite-${version}
    mkdir -p $out/share/java
    cp aptasuite-${version}.jar $out/share/java/
    cp -r lib $out/share/java/

    mkdir -p $out/bin
    makeWrapper ${jdk}/bin/java $out/bin/aptasuite \
      --add-flags "-jar $out/share/java/aptasuite-${version}.jar"
  '';

  meta = with lib; {
    description = "Full-featured bioinformatics framework for HT-SELEX aptamer analysis (CLI + GUI)";
    homepage = "https://github.com/drivenbyentropy/aptasuite";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
    maintainers = [];
  };
}
