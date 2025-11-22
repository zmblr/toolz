{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  fetchurl,
  # Build
  cmake,
  ninja,
  scikit-build-core,
  pybind11,
  gzip,
  bash,
  # C++ dependencies
  abseil-cpp,
  pybind11-abseil,
  libcifpp,
  dssp,
  zlib,
  boost,
  # Runtime binaries
  hmmer,
  # Python dependencies
  absl-py,
  chex,
  dm-haiku,
  dm-tree,
  jax,
  jaxlib,
  jax-cuda12-plugin,
  jax-triton,
  jaxtyping,
  numpy,
  pillow,
  rdkit,
  scipy,
  triton,
  tqdm,
  typeguard,
  zstandard,
  # CUDA libraries
  nvidia-cuda-runtime-cu12,
  nvidia-cublas-cu12,
  nvidia-cudnn-cu12,
  nvidia-cusparse-cu12,
  nvidia-cusolver-cu12,
  nvidia-cufft-cu12,
  nvidia-cuda-cupti-cu12,
  nvidia-nccl-cu12,
  nvidia-nvjitlink-cu12,
}: let
  # PDB snapshot (2025-01-01) for reproducibility
  componentsCif = fetchurl {
    url = "https://pdbsnapshots.s3-us-west-2.amazonaws.com/20250101/pub/pdb/data/monomers/components.cif.gz";
    hash = "sha256-2bJpHBYaZiKF13HXKWZen6YqA4tJeBy31zu+HrlC+Fw=";
  };
in
  buildPythonPackage rec {
    pname = "alphafold3";
    version = "3.0.1";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "google-deepmind";
      repo = "alphafold3";
      rev = "v${version}";
      hash = "sha256-5kUTsQkdYVtMN8CasL5+xwBIfBKs2A36MCIg9Bo3kG0=";
    };

    patches = [
      # Check LIBCIFPP_DATA_DIR before site.getsitepackages() for withPackages support
      ./libcifpp-env-var-first.patch
    ];

    # Replace CMake FetchContent with system dependencies
    postPatch = ''
          substituteInPlace CMakeLists.txt \
            --replace-fail 'FetchContent_Declare(
        abseil-cpp
        GIT_REPOSITORY https://github.com/abseil/abseil-cpp
        GIT_TAG d7aaad83b488fd62bd51c81ecf16cd938532cc0a # 20240116.2
        EXCLUDE_FROM_ALL)

      FetchContent_Declare(
        pybind11
        GIT_REPOSITORY https://github.com/pybind/pybind11
        GIT_TAG 2e0815278cb899b20870a67ca8205996ef47e70f # v2.12.0
        EXCLUDE_FROM_ALL)

      FetchContent_Declare(
        pybind11_abseil
        GIT_REPOSITORY https://github.com/pybind/pybind11_abseil
        GIT_TAG bddf30141f9fec8e577f515313caec45f559d319 # HEAD @ 2024-08-07
        EXCLUDE_FROM_ALL)

      FetchContent_Declare(
        cifpp
        GIT_REPOSITORY https://github.com/pdb-redo/libcifpp
        GIT_TAG ac98531a2fc8daf21131faa0c3d73766efa46180 # v7.0.3
        # Don'"'"'t `EXCLUDE_FROM_ALL` as necessary for build_data.
      )

      FetchContent_Declare(
        dssp
        GIT_REPOSITORY https://github.com/PDB-REDO/dssp
        GIT_TAG 57560472b4260dc41f457706bc45fc6ef0bc0f10 # v4.4.7
        EXCLUDE_FROM_ALL)

      FetchContent_MakeAvailable(pybind11 abseil-cpp pybind11_abseil cifpp dssp)' \
            '# Use system-provided dependencies
      find_package(absl REQUIRED)
      find_package(pybind11 REQUIRED)
      find_package(cifpp REQUIRED)
      find_package(dssp REQUIRED)
      include_directories(${pybind11-abseil}/include)
      link_directories(${pybind11-abseil}/lib)
      add_library(pybind11_abseil::absl_casters INTERFACE IMPORTED)
      set_target_properties(pybind11_abseil::absl_casters PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${pybind11-abseil}/include")'
    '';

    postInstall = ''
      # Install database fetching script
      install -Dm755 $src/fetch_databases.sh $out/bin/fetch_databases.sh
      substituteInPlace $out/bin/fetch_databases.sh \
        --replace-fail '#!/bin/bash' '#!${bash}/bin/bash'
    '';

    nativeBuildInputs = [
      cmake
      ninja
      scikit-build-core
      pybind11
      gzip
    ];

    buildInputs = [
      abseil-cpp
      pybind11-abseil
      libcifpp
      dssp
      zlib
      boost
    ];

    # HMMER is needed for sequence alignment but not propagated by withPackages
    # Users should include HMMER in their environment (e.g., via devShell or CLI package)
    propagatedBuildInputs = [hmmer];

    dependencies = [
      absl-py
      chex
      dm-haiku
      dm-tree
      jax
      jaxlib
      jax-cuda12-plugin
      jax-triton
      jaxtyping
      numpy
      pillow
      rdkit
      scipy
      triton
      tqdm
      typeguard
      zstandard
      nvidia-cuda-runtime-cu12
      nvidia-cublas-cu12
      nvidia-cudnn-cu12
      nvidia-cusparse-cu12
      nvidia-cusolver-cu12
      nvidia-cufft-cu12
      nvidia-cuda-cupti-cu12
      nvidia-nccl-cu12
      nvidia-nvjitlink-cu12
    ];

    dontUseCmakeConfigure = true;
    dontCheckRuntimeDeps = true; # rdkit is available via dependencies

    pythonImportsCheck = ["alphafold3"];
    doCheck = false; # Tests require model weights

    passthru = {
      inherit componentsCif; # For pickle generation in python-packages.nix
    };

    meta = {
      description = "Accurate structure prediction of biomolecular interactions with AlphaFold 3";
      longDescription = ''
        AlphaFold 3 predicts the structure and interactions of biological molecules.
        Model parameters must be obtained separately from Google DeepMind.
        Requires CUDA 12.x GPU for inference.
      '';
      homepage = "https://github.com/google-deepmind/alphafold3";
      changelog = "https://github.com/google-deepmind/alphafold3/releases/tag/v${version}";
      license = lib.licenses.cc-by-nc-sa-40;
      platforms = lib.platforms.linux;
    };
  }
