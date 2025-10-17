{
  lib,
  python3,
  fetchPypi,
  zlib-ng,
  callPackage,
}: let
  xopen = callPackage ./xopen.nix {inherit lib python3 zlib-ng;};
  dnaio = callPackage ./dnaio.nix {inherit lib python3 fetchPypi zlib-ng callPackage;};
in
  python3.pkgs.buildPythonPackage rec {
    pname = "cutadapt";
    version = "5.1";

    format = "pyproject";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-a8djRcCkX2toDLEWTkjrH4GBXHZOxHEoSrYjTGZTuTc=";
    };

    nativeBuildInputs = with python3.pkgs; [
      setuptools
      setuptools-scm
      cython
    ];

    propagatedBuildInputs =
      [
        xopen
        dnaio
      ]
      ++ lib.optionals python3.pkgs.stdenv.isLinux [
        python3.pkgs.isal
      ];

    SETUPTOOLS_SCM_PRETEND_VERSION = version;

    pythonImportsCheck = ["cutadapt"];

    meta = with lib; {
      description = "Tool to remove adapter sequences from sequencing reads";
      homepage = "https://github.com/marcelm/cutadapt";
      license = licenses.mit;
      mainProgram = "cutadapt";
    };
  }
