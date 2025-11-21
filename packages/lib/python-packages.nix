{
  lib,
  callPackage,
  stdenv,
  regularPackages,
}: let
  byNamePackage = import ./by-name.nix;
in
  pySelf: _pySuper:
    {
      # Cross-platform Python packages
      # keep-sorted start
      cutadapt = pySelf.callPackage (byNamePackage "cutadapt") {};
      dnaio = pySelf.callPackage (byNamePackage "dnaio") {};
      finch-clust = pySelf.callPackage (byNamePackage "finch-clust") {};
      forgi = pySelf.callPackage (byNamePackage "forgi") {};
      jax = pySelf.callPackage (byNamePackage "jax") {};
      jax-cuda12-pjrt = pySelf.callPackage (byNamePackage "jax-cuda12-pjrt") {};
      jax-cuda12-plugin = pySelf.callPackage (byNamePackage "jax-cuda12-plugin") {};
      jax-triton = pySelf.callPackage (byNamePackage "jax-triton") {};
      jaxlib = pySelf.callPackage (byNamePackage "jaxlib") {};
      jaxtyping = pySelf.callPackage (byNamePackage "jaxtyping") {};
      logging-exceptions = pySelf.callPackage (byNamePackage "logging-exceptions") {};
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
      rapids-build-backend = pySelf.callPackage (byNamePackage "rapids-build-backend") {};
      typeguard = pySelf.callPackage (byNamePackage "typeguard") {};
      xopen = pySelf.callPackage (byNamePackage "xopen") {};
      # keep-sorted end
    }
    // lib.optionalAttrs stdenv.isLinux
    {
      # Linux-only Python packages
      alphafold3 = let
        alphafold3-base = pySelf.callPackage ../by-name/al/alphafold3/base.nix {};
        inherit (alphafold3-base.passthru) componentsCif;

        # Add components.cif for pickle generation
        alphafold3-base-with-cif =
          pySelf.pkgs.runCommand "python3.12-alphafold3-with-cif-${alphafold3-base.version}" {
            inherit (alphafold3-base) meta;
            passthru = alphafold3-base.passthru or {};
            nativeBuildInputs = [pySelf.pkgs.gzip];
          } ''
            cp -r ${alphafold3-base} $out
            chmod -R +w $out

            SITE_PACKAGES="lib/${pySelf.python.libPrefix}/site-packages"
            mkdir -p $out/$SITE_PACKAGES/share/libcifpp
            gunzip -c ${componentsCif} > $out/$SITE_PACKAGES/share/libcifpp/components.cif

            chmod -R -w $out
          '';

        pythonEnv = pySelf.python.withPackages (_ps: [alphafold3-base-with-cif]);

        # Generate CCD pickle files at build time
        pickle-data =
          pySelf.pkgs.runCommand "alphafold3-pickle-data" {
            nativeBuildInputs = [pythonEnv pySelf.pkgs.gzip];
          } ''
            mkdir -p $out

            python3 -c "import alphafold3.cpp" || {
              echo "Error: C++ module import failed"
              exit 1
            }

            gunzip -c ${componentsCif} > $out/components.cif.tmp

            python3 -m alphafold3.constants.converters.ccd_pickle_gen \
              $out/components.cif.tmp $out/ccd.pickle || exit 1

            rm $out/components.cif.tmp
            python3 <<EOF
            import pickle, re

            with open('$out/ccd.pickle', 'rb') as f:
                ccd = pickle.load(f)

            glycans_linking, glycans_other, ions = [], [], []
            for name, comp in ccd.items():
                if name == 'UNX': continue
                comp_type = comp['_chem_comp.type'][0].lower()
                if re.findall(r'\\bsaccharide\\b', comp_type):
                    (glycans_linking if 'linking' in comp_type else glycans_other).append(name)
                if re.findall(r'\\bion\\b', comp['_chem_comp.name'][0].lower()):
                    ions.append(name)

            with open('$out/chemical_component_sets.pickle', 'wb') as f:
                pickle.dump({
                    'glycans_linking': frozenset(glycans_linking),
                    'glycans_other': frozenset(glycans_other),
                    'ions': frozenset(ions),
                }, f)
            EOF
          '';
      in
        alphafold3-base.overrideAttrs (oldAttrs: {
          pname = "alphafold3";
          nativeBuildInputs = oldAttrs.nativeBuildInputs or [] ++ [pickle-data pySelf.pkgs.gzip];

          postInstall =
            (oldAttrs.postInstall or "")
            + ''
              SITE_PACKAGES="lib/${pySelf.python.libPrefix}/site-packages"

              mkdir -p $out/$SITE_PACKAGES/share/libcifpp
              gunzip -c ${componentsCif} > $out/$SITE_PACKAGES/share/libcifpp/components.cif

              mkdir -p $out/$SITE_PACKAGES/alphafold3/constants/converters
              cp ${pickle-data}/*.pickle $out/$SITE_PACKAGES/alphafold3/constants/converters/
            '';

          passthru =
            (oldAttrs.passthru or {})
            // {
              pickles = pickle-data;
              base = alphafold3-base;
            };

          meta =
            (oldAttrs.meta or {})
            // {
              description = "AlphaFold 3 structure prediction with pre-generated pickle files";
            };
        });
      cudf-cu12 = pySelf.callPackage (byNamePackage "cudf-cu12") {
        inherit (regularPackages) cuda-compat;
      };
      libcudf-cu12 = pySelf.callPackage (byNamePackage "libcudf-cu12") {};
      libkvikio-cu12 = pySelf.callPackage (byNamePackage "libkvikio-cu12") {};
      librmm-cu12 = pySelf.callPackage (byNamePackage "librmm-cu12") {};
      pylibcudf-cu12 = pySelf.callPackage (byNamePackage "pylibcudf-cu12") {};
      viennarna-hpc = pySelf.toPythonModule (
        callPackage (byNamePackage "viennarna-hpc") {
          python3 = pySelf.python;
        }
      );
    }
