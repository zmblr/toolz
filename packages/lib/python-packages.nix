{
  lib,
  stdenv,
  pkgs,
}: let
  byNamePackage = import ./by-name.nix;
in
  pySelf: _pySuper:
    {
      # Cross-platform Python packages
      # keep-sorted start
      cuda-bindings = pySelf.callPackage (byNamePackage "cuda-bindings") {};
      cuda-core = pySelf.callPackage (byNamePackage "cuda-core") {};
      cuda-pathfinder = pySelf.callPackage (byNamePackage "cuda-pathfinder") {};
      cuda-python = pySelf.callPackage (byNamePackage "cuda-python") {};
      cuda-toolkit = pySelf.callPackage (byNamePackage "cuda-toolkit") {};
      cutadapt = pySelf.callPackage (byNamePackage "cutadapt") {};
      dnaio = pySelf.callPackage (byNamePackage "dnaio") {};
      finch-clust = pySelf.callPackage (byNamePackage "finch-clust") {};
      forgi = pySelf.callPackage (byNamePackage "forgi") {};
      logging-exceptions = pySelf.callPackage (byNamePackage "logging-exceptions") {};
      mkdocs-static-i18n = pySelf.callPackage (byNamePackage "mkdocs-static-i18n") {};
      numba-cuda = pySelf.callPackage (byNamePackage "numba-cuda") {};
      nupack = pySelf.callPackage (byNamePackage "nupack") {};
      nvidia-cublas-cu12 = pySelf.callPackage (byNamePackage "nvidia-cublas-cu12") {};
      nvidia-cuda-cupti-cu12 = pySelf.callPackage (byNamePackage "nvidia-cuda-cupti-cu12") {};
      nvidia-cuda-nvcc-cu12 = pySelf.callPackage (byNamePackage "nvidia-cuda-nvcc-cu12") {};
      nvidia-cuda-runtime-cu12 = pySelf.callPackage (byNamePackage "nvidia-cuda-runtime-cu12") {};
      nvidia-cudnn-cu12 = pySelf.callPackage (byNamePackage "nvidia-cudnn-cu12") {};
      nvidia-cufft-cu12 = pySelf.callPackage (byNamePackage "nvidia-cufft-cu12") {};
      nvidia-cusolver-cu12 = pySelf.callPackage (byNamePackage "nvidia-cusolver-cu12") {};
      nvidia-cusparse-cu12 = pySelf.callPackage (byNamePackage "nvidia-cusparse-cu12") {};
      nvidia-nccl-cu12 = pySelf.callPackage (byNamePackage "nvidia-nccl-cu12") {};
      nvidia-nvjitlink-cu12 = pySelf.callPackage (byNamePackage "nvidia-nvjitlink-cu12") {};
      nvtx = pySelf.callPackage (byNamePackage "nvtx") {};
      pyclibrary = pySelf.callPackage (byNamePackage "pyclibrary") {};
      # NOTE: pyarrow removed from global overlay to avoid conflicts
      # Now used as local dependency in cudf-cu12
      # NOTE: pymdown-extensions removed from global overlay to avoid conflicts
      # Now used as local dependency in zensical
      rapids-build-backend = pySelf.callPackage (byNamePackage "rapids-build-backend") {};
      rapids-dask-dependency = pySelf.callPackage (byNamePackage "rapids-dask-dependency") {};
      rapids-logger = pySelf.callPackage (byNamePackage "rapids-logger") {};
      xopen = pySelf.callPackage (byNamePackage "xopen") {};
      zensical = pySelf.callPackage (byNamePackage "zensical") {};
      # keep-sorted end
    }
    // lib.optionalAttrs stdenv.isLinux
    {
      # Linux-only Python packages
      cudf-cu12 = pySelf.callPackage (byNamePackage "cudf-cu12") {
        inherit (pkgs) cuda-compat;
      };
      cugraph-cu12 = pySelf.callPackage (byNamePackage "cugraph-cu12") {
        inherit (pkgs) cuda-compat;
      };
      dask-cuda = pySelf.callPackage (byNamePackage "dask-cuda") {};
      dask-cudf-cu12 = pySelf.callPackage (byNamePackage "dask-cudf-cu12") {};
      distributed-ucxx-cu12 = pySelf.callPackage (byNamePackage "distributed-ucxx-cu12") {};
      libcudf-cu12 = pySelf.callPackage (byNamePackage "libcudf-cu12") {};
      libcugraph-cu12 = pySelf.callPackage (byNamePackage "libcugraph-cu12") {};
      libkvikio-cu12 = pySelf.callPackage (byNamePackage "libkvikio-cu12") {};
      libraft-cu12 = pySelf.callPackage (byNamePackage "libraft-cu12") {};
      librmm-cu12 = pySelf.callPackage (byNamePackage "librmm-cu12") {};
      libucx-cu12 = pySelf.callPackage (byNamePackage "libucx-cu12") {};
      libucxx-cu12 = pySelf.callPackage (byNamePackage "libucxx-cu12") {};
      pylibcugraph-cu12 = pySelf.callPackage (byNamePackage "pylibcugraph-cu12") {};
      pylibraft-cu12 = pySelf.callPackage (byNamePackage "pylibraft-cu12") {};
      raft-dask-cu12 = pySelf.callPackage (byNamePackage "raft-dask-cu12") {};
      rmm-cu12 = pySelf.callPackage (byNamePackage "rmm-cu12") {};
      ucxx-cu12 = pySelf.callPackage (byNamePackage "ucxx-cu12") {};
      pylibcudf-cu12 = pySelf.callPackage (byNamePackage "pylibcudf-cu12") {};
    }
