{
  lib,
  symlinkJoin,
  makeWrapper,
  pkgs,
  python3Packages,
  pythonOverlayFunc,
  hmmer,
}: let
  alphafold3-with-pickles = python3Packages.alphafold3;

  cudaModuleNames = [
    "cuda_runtime"
    "cublas"
    "cudnn"
    "cusparse"
    "cusolver"
    "cufft"
    "cuda_cupti"
    "nccl"
    "nvjitlink"
  ];

  alphafold3-with-cli = alphafold3-with-pickles.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [makeWrapper];

    postInstall =
      (oldAttrs.postInstall or "")
      + ''
        mkdir -p $out/share/alphafold3
        cp ${alphafold3-with-pickles.base.src}/run_alphafold.py $out/share/alphafold3/
      '';

    passthru =
      (oldAttrs.passthru or {})
      // {
        # GPU environment setup: alphafold3.mkShellHook python
        mkShellHook = python: let
          cudaLibsPath =
            lib.concatMapStringsSep ":" (
              name: "${python}/${python3Packages.python.sitePackages}/nvidia/${name}/lib"
            )
            cudaModuleNames;
          libcifppDataDir = "${python}/${python3Packages.python.sitePackages}/share/libcifpp";
        in ''
          export LD_LIBRARY_PATH="${pkgs.addDriverRunpath.driverLink}/lib:${cudaLibsPath}:''${LD_LIBRARY_PATH:-}"
          export LIBCIFPP_DATA_DIR="${libcifppDataDir}"
        '';
      };

    meta =
      (oldAttrs.meta or {})
      // {
        description = "AlphaFold 3 structure prediction with pre-generated pickle files";
        longDescription = ''
          AlphaFold 3 predicts biomolecular structures and interactions.

          Includes: CCD pickles, HMMER tools, CUDA 12.x support.
          Requires: CUDA GPU, model weights from DeepMind (https://github.com/google-deepmind/alphafold3)
        '';
      };
  });

  python3WithOverlay = pkgs.python3.override {
    packageOverrides = pythonOverlayFunc;
  };
  python-with-alphafold3 = python3WithOverlay.withPackages (ps: [ps.alphafold3]);
  cudaLibsPath =
    lib.concatMapStringsSep ":" (
      name: "${python-with-alphafold3}/${python-with-alphafold3.sitePackages}/nvidia/${name}/lib"
    )
    cudaModuleNames;
in
  symlinkJoin {
    name = "alphafold3-${alphafold3-with-cli.version}";
    paths = [alphafold3-with-cli hmmer];
    inherit (alphafold3-with-cli) meta;

    passthru =
      alphafold3-with-cli.passthru
      // {
        pythonPackage = python3Packages.alphafold3;
        pythonEnv = python-with-alphafold3;
      };

    nativeBuildInputs = [makeWrapper];
    postBuild = ''
      if [ -d ${alphafold3-with-cli}/lib ]; then
        rm -rf $out/lib
        ln -s ${alphafold3-with-cli}/lib $out/lib
      fi

      makeWrapper ${python-with-alphafold3}/bin/python $out/bin/alphafold3 \
        --prefix LD_LIBRARY_PATH : "${pkgs.addDriverRunpath.driverLink}/lib:${cudaLibsPath}" \
        --add-flags "${alphafold3-with-cli}/share/alphafold3/run_alphafold.py"
    '';
  }
