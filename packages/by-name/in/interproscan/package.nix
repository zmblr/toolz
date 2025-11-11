{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  perl,
  python3,
  jdk11,
  zlib,
  bzip2,
  gfortran,
  pcre2,
  coreutils,
}:
stdenv.mkDerivation rec {
  pname = "interproscan";
  version = "5.76-107.0";

  src = fetchurl {
    url = "https://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/${version}/interproscan-${version}-64-bit.tar.gz";
    hash = "sha256-SKf2p3dRT4RPJj2sWQgFC/8AwoE0EnGAglgabQbrXdc=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
    bzip2
    pcre2
    gfortran.cc.lib
  ];

  sourceRoot = ".";

  dontStrip = true;

  dontConfigure = true;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cd interproscan-${version}


    mkdir -p $out/{bin,share/interproscan}


    cp -r ./* $out/share/interproscan/


    chmod -R u+w $out/share/interproscan

    runHook postInstall
  '';

  postInstall = ''
    cd $out/share/interproscan


    substituteInPlace interproscan.properties \
      --replace-warn "perl.command=perl" "perl.command=${perl}/bin/perl" \
      --replace-warn "python3.command=python3" "python3.command=${python3}/bin/python3"


    find $out/share/interproscan -type f -name "*.sh" -exec chmod +x {} \;
    find $out/share/interproscan/bin -type f -exec chmod +x {} \;


    substituteInPlace setup.py \
      --replace-warn "cmd = ['bin/" "cmd = ['$out/share/interproscan/bin/"



    echo "Indexing HMM models..."
    export PATH="$out/share/interproscan/bin/hmmer/hmmer3/3.3:$PATH"
    ${python3}/bin/python3 setup.py -f interproscan.properties || {
      echo "Warning: HMM indexing failed, but continuing..."
      echo "You may need to run setup.py manually after installation"
    }


    makeWrapper $out/share/interproscan/interproscan.sh $out/bin/interproscan \
      --set JAVA_HOME "${jdk11}" \
      --set INTERPROSCAN_HOME "$out/share/interproscan" \
      --prefix PATH : "${lib.makeBinPath [
      jdk11
      perl
      python3
      coreutils
    ]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [
      stdenv.cc.cc.lib
      zlib
      bzip2
      pcre2
      gfortran.cc.lib
    ]}"
  '';

  postFixup = ''

    find $out/share/interproscan -type f -name "*.sh" -exec \
      sed -i "1s|^

    find $out/share/interproscan -type f -name "*.pl" -exec \
      sed -i "1s|^

    find $out/share/interproscan -type f -name "*.py" -exec \
      sed -i "1s|^
  '';

  meta = with lib; {
    description = "Protein sequence analysis and classification";
    longDescription = ''
      InterProScan is a comprehensive tool that combines different protein
      signature recognition methods into one resource.

      Note: HMM models may need to be indexed on first use if automatic
      indexing fails during build. Run:
        cd $INTERPROSCAN_HOME && python3 setup.py -f interproscan.properties
    '';
    homepage = "https://www.ebi.ac.uk/interpro/";
    license = licenses.asl20;
    platforms = ["x86_64-linux"];
    sourceProvenance = with sourceTypes; [binaryNativeCode];
  };
}
