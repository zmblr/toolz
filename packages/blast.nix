{
  blast,
  coreutils,
  curl,
  findutils,
  gnutar,
  google-cloud-sdk,
  gzip,
  lib,
  makeWrapper,
  perl,
  stdenv,
  wget,
}:
stdenv.mkDerivation {
  pname = "blast";
  inherit (blast) version;

  inherit (blast) src;

  nativeBuildInputs = [makeWrapper perl];

  buildInputs = [
    curl
    wget
    findutils
    gnutar
    gzip
    coreutils
  ];

  buildPhase = ''
    runHook preBuild
    cp -r ${blast}/bin $TMP/bin
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -r $TMP/bin/* $out/bin/

    substituteInPlace $out/bin/update_blastdb.pl \
      --replace '/usr/bin/xargs' '${findutils}/bin/xargs' \
      --replace 'foreach (qw(/usr/local/bin /usr/bin))' \
                'foreach (qw(${curl}/bin ${wget}/bin /usr/local/bin /usr/bin))' \
      --replace 'local $ENV{PATH} = "/bin:/usr/bin";' \
                'local $ENV{PATH} = "${
      lib.makeBinPath [
        gnutar
        gzip
        coreutils
      ]
    }:$ENV{PATH}";'

    wrapProgram $out/bin/update_blastdb.pl \
      --prefix PATH : ${
      lib.makeBinPath [
        curl
        wget
        findutils
        gnutar
        gzip
        coreutils
        google-cloud-sdk
      ]
    }

    chmod +x $out/bin/update_blastdb.pl
    runHook postInstall
  '';

  meta =
    blast.meta
    // {
      description = "NCBI BLAST with fully self-contained update_blastdb.pl";
    };
}
