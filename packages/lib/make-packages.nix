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
  {
    # keep-sorted start
    aptasuite = callPackage (byNamePackage "aptasuite") {};
    bbtools = callPackage (byNamePackage "bbtools") {};
    fastaptamer = callPackage (byNamePackage "fastaptamer") {};
    flash = callPackage (byNamePackage "flash") {};
    jellyfish = callPackage (byNamePackage "jellyfish") {};
    jellyfish-full = callPackage (byNamePackage "jellyfish-full") {};
    kmc = callPackage (byNamePackage "kmc") {};
    kmc-full = callPackage (byNamePackage "kmc-full") {};
    nextflow = callPackage (byNamePackage "nextflow") {};
    # keep-sorted end
  }
  // lib.optionalAttrs stdenv.isLinux {
    blast = callPackage (byNamePackage "blast") {};
    viennarna-hpc = callPackage (byNamePackage "viennarna-hpc") {};
  }
