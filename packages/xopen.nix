{
  lib,
  python3,
  zlib-ng,
  isa-l,
}: let
  python = python3;
in
  python.pkgs.buildPythonPackage rec {
    pname = "xopen";
    version = "2.0.2";
    format = "pyproject";

    src = python.pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-8Z2D3kcPWoFyXfAUAYDscdGYMRodfa1I9UZ7StXfYVQ=";
    };

    nativeBuildInputs = with python.pkgs; [
      setuptools
      setuptools-scm
    ];

    buildInputs = [zlib-ng];

    propagatedBuildInputs = with python.pkgs;
      lib.optionals stdenv.isLinux [isa-l]
      ++ lib.optionals (python.pythonOlder "3.10") [importlib-metadata];

    dontCheckRuntimeDeps = true;
    pythonImportsCheck = ["xopen"];

    meta = with lib; {
      description = "Open compressed files transparently";
      homepage = "https://github.com/pycompression/xopen";
      license = licenses.mit;
      platforms = platforms.unix;
    };
  }
