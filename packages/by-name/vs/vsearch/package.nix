{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  zlib,
  bzip2,
}:
stdenv.mkDerivation rec {
  pname = "vsearch";
  version = "2.30.1";

  src = fetchFromGitHub {
    owner = "torognes";
    repo = "vsearch";
    rev = "v${version}";
    sha256 = "sha256-v4Y9CIb14AmhlZg3V9h+BeS/8yfoqIk34XdlmAeYTUI=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    zlib
    bzip2
  ];

  configureFlags = [
    "--enable-bzip2"
    "--enable-zlib"
  ];

  enableParallelBuilding = true;

  doCheck = false;

  meta = with lib; {
    description = "Versatile open-source tool for metagenomics (USEARCH alternative)";
    longDescription = ''
      VSEARCH is a versatile open-source tool for processing and preparing
      metagenomics, genomics and population genomics nucleotide sequence data.
      It supports de novo and reference based chimera detection, clustering,
      dereplication, full-length and prefix dereplication, masking,
      all-vs-all pairwise global alignment, exact and global alignment
      searching, shuffling, sorting and sampling.
    '';
    homepage = "https://github.com/torognes/vsearch";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    mainProgram = "vsearch";
  };
}
