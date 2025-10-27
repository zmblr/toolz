{
  lib,
  callPackage,
  stdenv,
}: let
  byNamePackage = name: let
    firstTwo = builtins.substring 0 2 name;
  in
    ../by-name + "/${firstTwo}/${name}/package.nix";
in
  pySelf: _pySuper:
    {
      # keep-sorted start
      cutadapt = pySelf.callPackage (byNamePackage "cutadapt") {};
      dnaio = pySelf.callPackage (byNamePackage "dnaio") {};
      forgi = pySelf.callPackage (byNamePackage "forgi") {};
      logging-exceptions = pySelf.callPackage (byNamePackage "logging-exceptions") {};
      xopen = pySelf.callPackage (byNamePackage "xopen") {};
      # keep-sorted end
    }
    // lib.optionalAttrs stdenv.isLinux {
      viennarna-hpc = pySelf.toPythonModule (
        callPackage (byNamePackage "viennarna-hpc") {
          python3 = pySelf.python;
        }
      );
    }
