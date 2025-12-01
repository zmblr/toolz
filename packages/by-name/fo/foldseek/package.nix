{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  cargo,
  rustc,
  perl,
  zlib,
  bzip2,
  llvmPackages,
  config,
  cudaSupport ? config.cudaSupport or false,
  cudaPackages ? {},
}: let
  inherit (lib) optionals;
in
  stdenv.mkDerivation rec {
    pname = "foldseek";
    version = "10-941cd33";

    src = fetchFromGitHub {
      owner = "steineggerlab";
      repo = "foldseek";
      rev = version;
      # fetchSubmodules = false to avoid empty-URL kompute submodule
      # lib/mmseqs and lib/prostt5 are NOT submodules, they're included directly
      hash = "sha256-tZ0oeYPlTXvr/NR7djEvdbuF2K2bMGKC+9FFgsZgY38=";
      fetchSubmodules = false;
    };

    postPatch = ''
      # Fix shebang for xxdi.pl Perl scripts used in build
      patchShebangs lib/mmseqs/cmake/xxdi.pl
      patchShebangs cmake/xxdi.pl

      # Remove obsolete CMake policy that's no longer supported
      substituteInPlace CMakeLists.txt \
        --replace-fail 'cmake_policy(SET CMP0060 OLD)' '# cmake_policy(SET CMP0060 OLD) # removed: no longer supported'
    '';

    nativeBuildInputs =
      [
        cmake
        pkg-config
        cargo
        rustc
        perl
      ]
      ++ optionals cudaSupport [
        cudaPackages.cuda_nvcc
      ];

    buildInputs =
      [
        zlib
        bzip2
        llvmPackages.openmp
      ]
      ++ optionals cudaSupport [
        cudaPackages.cuda_cudart
        cudaPackages.libcublas
      ];

    cmakeFlags =
      [
        # Workaround for CMake 3.31+ removing compatibility with cmake_minimum_required < 3.5
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
      ]
      ++ optionals stdenv.hostPlatform.isx86_64 [
        "-DHAVE_AVX2=1"
      ]
      ++ optionals stdenv.hostPlatform.isAarch64 [
        "-DHAVE_ARM8=1"
      ]
      ++ optionals cudaSupport [
        "-DENABLE_CUDA=1"
        "-DCMAKE_CUDA_ARCHITECTURES=75;80;86;89;90"
      ];

    passthru = {
      inherit cudaSupport;
    };

    meta = {
      description = "Fast and sensitive protein structure search";
      homepage = "https://github.com/steineggerlab/foldseek";
      license = lib.licenses.gpl3Plus;
      platforms =
        if cudaSupport
        then lib.platforms.linux
        else lib.platforms.unix;
      mainProgram = "foldseek";
    };
  }
