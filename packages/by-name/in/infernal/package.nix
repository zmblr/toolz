{
  lib,
  stdenv,
  fetchurl,
  perl,
}:
stdenv.mkDerivation rec {
  pname = "infernal";
  version = "1.1.5";

  src = fetchurl {
    url = "http://eddylab.org/infernal/infernal-${version}.tar.gz";
    sha256 = "sha256-rU3a4C+STKfIW8jEp5yfh1r435autyZwL6mFy+dSSX8=";
  };

  nativeBuildInputs = [
    perl
  ];

  enableParallelBuilding = true;

  configureFlags = [
    "--enable-sse"
  ];

  doCheck = false;

  postInstall = ''
    if [ -d hmmer ]; then
      (cd hmmer && make install)
    fi

    if [ -d easel ]; then
      (cd easel && make install)
    fi
  '';

  meta = with lib; {
    description = "Inference of RNA secondary structure alignments using covariance models";
    longDescription = ''
      Infernal ("INFERence of RNA ALignment") is for searching DNA sequence
      databases for RNA structure and sequence similarities. It is an
      implementation of covariance models (CMs), which are statistical models
      of RNA secondary structure and sequence consensus. Infernal is the
      software engine underlying the Rfam RNA database.
    '';
    homepage = "http://eddylab.org/infernal";
    license = licenses.bsd3;
    platforms = platforms.unix;
    mainProgram = "cmsearch";
  };
}
