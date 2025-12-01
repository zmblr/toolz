{
  absl-py,
  autoPatchelfHook,
  buildPythonPackage,
  fetchurl,
  flatbuffers,
  lib,
  ml-dtypes,
  python,
  scipy,
  stdenv,
}: let
  version = "0.4.34";
  inherit (python) pythonVersion;

  # Direct URLs from PyPI (fetchPypi generates incorrect URLs for wheels in nixpkgs 25.11)
  srcs = {
    "3.10-x86_64-linux" = fetchurl {
      url = "https://files.pythonhosted.org/packages/e4/b0/a5bd34643c070e50829beec217189eab1acdfea334df1f9ddb4e5f8bec0f/jaxlib-0.4.34-cp310-cp310-manylinux2014_x86_64.whl";
      hash = "sha256-2A5mSIVUbm1RbnJh/j0VnQpHq/V/vugpnzc2chg9wtI=";
    };
    "3.10-aarch64-linux" = fetchurl {
      url = "https://files.pythonhosted.org/packages/dd/ea/12c836126419ca80248228f2236831617eedb1e3640c34c942606f33bb08/jaxlib-0.4.34-cp310-cp310-manylinux2014_aarch64.whl";
      hash = "sha256-PlgMnJMzkwOZm7u4hwtjJM3hXt5TSRcNwWa/Vkb9LMw=";
    };
    "3.10-aarch64-darwin" = fetchurl {
      url = "https://files.pythonhosted.org/packages/1e/67/6a344c357caad33e84b871925cd043b4218fc13a427266d1a1dedcb1c095/jaxlib-0.4.34-cp310-cp310-macosx_11_0_arm64.whl";
      hash = "sha256-RdcaLOPraiFSVXonuRt98dfVo/ozjQm9x9MgMiIZ3eA=";
    };

    "3.11-x86_64-linux" = fetchurl {
      url = "https://files.pythonhosted.org/packages/c7/d0/6bc81c0b1d507f403e6085ce76a429e6d7f94749d742199252e299dd1424/jaxlib-0.4.34-cp311-cp311-manylinux2014_x86_64.whl";
      hash = "sha256-O8/jpDpkqaMo+KPKoQzXe8jbEz9X8F3VL6w2Oyq1v18=";
    };
    "3.11-aarch64-linux" = fetchurl {
      url = "https://files.pythonhosted.org/packages/aa/06/3e09e794acf308e170905d732eca0d041449503c47505cc22e8ef78a989d/jaxlib-0.4.34-cp311-cp311-manylinux2014_aarch64.whl";
      hash = "sha256-Vx7wJYg1VIZRFZaabSjpQabpJOa0frtoQUpOKqxL/rA=";
    };
    "3.11-aarch64-darwin" = fetchurl {
      url = "https://files.pythonhosted.org/packages/66/78/d1535ee73fe505dc6c8831c19c4846afdce7df5acefb9f8ee885aa73d700/jaxlib-0.4.34-cp311-cp311-macosx_11_0_arm64.whl";
      hash = "sha256-yT2tCp1B+vmfHZ9vL7qrUL+y6FSFhGt7nqM1bvc+qqg=";
    };

    "3.12-x86_64-linux" = fetchurl {
      url = "https://files.pythonhosted.org/packages/e7/0d/4faf839e3c8ce2a5b615df64427be3e870899c72c0ebfb5859348150aba1/jaxlib-0.4.34-cp312-cp312-manylinux2014_x86_64.whl";
      hash = "sha256-SCcukDT/ho1DKM8AVaB4gv0r6T9Z37YoOvfeSR+dEpA=";
    };
    "3.12-aarch64-linux" = fetchurl {
      url = "https://files.pythonhosted.org/packages/af/09/cceae2d251a506b4297679d10ee9f5e905a6b992b0687d553c9470ffd1db/jaxlib-0.4.34-cp312-cp312-manylinux2014_aarch64.whl";
      hash = "sha256-GjB3HYX3f5urbPY0RV+l+j+jRYeGDtuYfV7ouW7gO8U=";
    };
    "3.12-aarch64-darwin" = fetchurl {
      url = "https://files.pythonhosted.org/packages/87/2e/8a75d3107c019c370c50c01acc205da33f9d6fba830950401a772a8e9f6d/jaxlib-0.4.34-cp312-cp312-macosx_11_0_arm64.whl";
      hash = "sha256-CW8Mo0nUH6aS0fL5r6u6HMn0Cn1PeldPiPru/k3ys/Q=";
    };
  };
in
  buildPythonPackage {
    pname = "jaxlib";
    inherit version;
    format = "wheel";

    src = srcs."${pythonVersion}-${stdenv.hostPlatform.system}"
      or (throw "jaxlib ${version} is not supported on ${stdenv.hostPlatform.system} with Python ${pythonVersion}");

    # Prebuilt wheels are dynamically linked against things that nix can't find.
    # Run `autoPatchelfHook` to automagically fix them.
    nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
    # Dynamic link dependencies
    buildInputs = [(lib.getLib stdenv.cc.cc)];

    dependencies = [
      absl-py
      flatbuffers
      ml-dtypes
      scipy
    ];

    pythonImportsCheck = ["jaxlib"];

    meta = {
      description = "XLA library for JAX (prebuilt wheel from PyPI)";
      homepage = "https://github.com/google/jax";
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      license = lib.licenses.asl20;
      platforms = lib.platforms.unix;
    };
  }
