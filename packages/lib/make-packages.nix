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
    }
    else {};
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
    nupack = callPackage (byNamePackage "nupack") {};
    vsearch = callPackage (byNamePackage "vsearch") {};
    # keep-sorted end
  }
  // externalPackages
  // lib.optionalAttrs stdenv.isLinux {
    # keep-sorted start
    blast = callPackage (byNamePackage "blast") {};
    viennarna-hpc = callPackage (byNamePackage "viennarna-hpc") {};
    # keep-sorted end
  }
