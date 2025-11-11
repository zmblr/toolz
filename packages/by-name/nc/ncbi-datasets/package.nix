{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
stdenv.mkDerivation rec {
  pname = "ncbi-datasets";
  version = "18.9.1";

  src =
    if stdenv.isLinux && stdenv.isx86_64
    then
      fetchurl {
        url = "https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/datasets";
        sha256 = "sha256-1accf8FA6hCeW3jVuMNHAvzqlhqJ+Qe+kO8taCX3S1Q=";
      }
    else if stdenv.isDarwin
    then
      fetchurl {
        url = "https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/mac/datasets";
        sha256 = lib.fakeSha256;
      }
    else if stdenv.isLinux && stdenv.isAarch64
    then
      fetchurl {
        url = "https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-arm64/datasets";
        sha256 = lib.fakeSha256;
      }
    else throw "Unsupported platform";

  nativeBuildInputs = lib.optionals stdenv.isLinux [
    autoPatchelfHook
  ];

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    install -Dm755 ${src} $out/bin/datasets

    runHook postInstall
  '';

  meta = with lib; {
    description = "NCBI Datasets command-line tools for downloading biological sequence data";
    longDescription = ''
      The NCBI Datasets command-line tools consist of datasets.
      Use datasets to download biological sequence data across all domains of life from NCBI.
      Use dataformat to convert metadata from JSON Lines format to other formats.
    '';
    homepage = "https://www.ncbi.nlm.nih.gov/datasets/docs/v2/";
    changelog = "https://github.com/ncbi/datasets/releases";
    license = licenses.publicDomain;
    platforms = platforms.unix;
    mainProgram = "datasets";
  };
}
