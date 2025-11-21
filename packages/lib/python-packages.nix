{
  lib,
  callPackage,
  stdenv,
}: let
  byNamePackage = import ./by-name.nix;
in
  pySelf: _pySuper:
    {
      # Cross-platform Python packages
      # keep-sorted start
      cutadapt = pySelf.callPackage (byNamePackage "cutadapt") {};
      dnaio = pySelf.callPackage (byNamePackage "dnaio") {};
      forgi = pySelf.callPackage (byNamePackage "forgi") {};
      logging-exceptions = pySelf.callPackage (byNamePackage "logging-exceptions") {};
      nupack = pySelf.callPackage (byNamePackage "nupack") {};
      xopen = pySelf.callPackage (byNamePackage "xopen") {};
      # keep-sorted end
    }
    // lib.optionalAttrs stdenv.isLinux
    {
      # Linux-only Python packages
      viennarna-hpc = pySelf.toPythonModule (
        callPackage (byNamePackage "viennarna-hpc") {
          python3 = pySelf.python;
        }
      );
    }
