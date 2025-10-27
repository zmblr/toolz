{
  lib,
  callPackage,
  stdenv,
  inputs ? {},
  system ? null,
}: let
  byNamePackage = name: let
    firstTwo = builtins.substring 0 2 name;
  in
    ../by-name + "/${firstTwo}/${name}/package.nix";

  externalPythonPackages = _pySelf: _pySuper:
    if inputs != {} && system != null
    then {
      # some-py-pkg = inputs.some-flake.packages.${system}.some-py-pkg or null;
    }
    else {};
in
  pySelf: pySuper:
    {
      # keep-sorted start
      cutadapt = pySelf.callPackage (byNamePackage "cutadapt") {};
      dnaio = pySelf.callPackage (byNamePackage "dnaio") {};
      forgi = pySelf.callPackage (byNamePackage "forgi") {};
      logging-exceptions = pySelf.callPackage (byNamePackage "logging-exceptions") {};
      xopen = pySelf.callPackage (byNamePackage "xopen") {};
      # keep-sorted end
    }
    // (externalPythonPackages pySelf pySuper)
    // lib.optionalAttrs stdenv.isLinux {
      viennarna-hpc = pySelf.toPythonModule (
        callPackage (byNamePackage "viennarna-hpc") {
          python3 = pySelf.python;
        }
      );
    }
