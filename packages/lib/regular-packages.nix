{
  lib,
  callPackage,
  stdenv,
  pkgs,
  pythonOverlayFunc,
  python3PackagesExtended,
}: let
  byNamePackage = import ./by-name.nix;
in
  {
    # Cross-platform packages
    aptasuite = callPackage (byNamePackage "aptasuite") {};
    bbtools = callPackage (byNamePackage "bbtools") {};
    edirect = callPackage (byNamePackage "edirect") {};
    fastaptamer = callPackage (byNamePackage "fastaptamer") {};
    flash = callPackage (byNamePackage "flash") {};
    infernal = callPackage (byNamePackage "infernal") {};
    jellyfish = callPackage (byNamePackage "jellyfish") {};
    jellyfish-full = callPackage (byNamePackage "jellyfish-full") {};
    kmc = callPackage (byNamePackage "kmc") {};
    kmc-full = callPackage (byNamePackage "kmc-full") {};
    locarna = callPackage (byNamePackage "locarna") {};
    ncbi-dataformat = callPackage (byNamePackage "ncbi-dataformat") {};
    ncbi-datasets = callPackage (byNamePackage "ncbi-datasets") {};
    nextflow = callPackage (byNamePackage "nextflow") {};
    openzl = callPackage (byNamePackage "openzl") {};
    vsearch = callPackage (byNamePackage "vsearch") {};
  }
  // lib.optionalAttrs stdenv.isLinux {
    # Linux-only packages
    alphafold3 = callPackage (byNamePackage "alphafold3") {
      inherit pkgs pythonOverlayFunc;
      python3Packages = python3PackagesExtended;
    };
    blast = callPackage (byNamePackage "blast") {};
    interproscan = callPackage (byNamePackage "interproscan") {};
    viennarna-hpc = callPackage (byNamePackage "viennarna-hpc") {};
  }
