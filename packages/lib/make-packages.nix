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

  externalPackages =
    if inputs != {} && system != null
    then {
      seqtable = inputs.seqtable.packages.${system}.seqtable or null;
      selexqc = inputs.selexqc.packages.${system}.selexqc or null;
    }
    else {};
in
  {
    # keep-sorted start
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
    nupack = callPackage (byNamePackage "nupack") {};
    openzl = callPackage (byNamePackage "openzl") {};
    vsearch = callPackage (byNamePackage "vsearch") {};
    # keep-sorted end
  }
  // externalPackages
  // lib.optionalAttrs stdenv.isLinux {
    # keep-sorted start
    blast = callPackage (byNamePackage "blast") {};
    interproscan = callPackage (byNamePackage "interproscan") {};
    viennarna-hpc = callPackage (byNamePackage "viennarna-hpc") {};
    # keep-sorted end
  }
