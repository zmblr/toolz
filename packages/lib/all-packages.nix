{
  pkgs,
  inputs ? {},
  system ? null,
  ...
}: let
  inherit (pkgs) lib callPackage;

  byNamePackage = name: let
    firstTwo = builtins.substring 0 2 name;
  in
    ../by-name + "/${firstTwo}/${name}/package.nix";

  pythonOverlay = pySelf: _pySuper:
    {
      # keep-sorted start
      cutadapt = pySelf.callPackage (byNamePackage "cutadapt") {};
      dnaio = pySelf.callPackage (byNamePackage "dnaio") {};
      forgi = pySelf.callPackage (byNamePackage "forgi") {};
      logging-exceptions = pySelf.callPackage (byNamePackage "logging-exceptions") {};
      xopen = pySelf.callPackage (byNamePackage "xopen") {};
      # keep-sorted end
    }
    // lib.optionalAttrs pkgs.stdenv.isLinux {
      viennarna-hpc = pySelf.toPythonModule (
        callPackage (byNamePackage "viennarna-hpc") {
          python3 = pySelf.python;
        }
      );
    };

  python3PackagesExtended = pkgs.python3Packages.overrideScope pythonOverlay;

  regularPackages =
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
      vsearch = callPackage (byNamePackage "vsearch") {};
      # keep-sorted end
    }
    // lib.optionalAttrs pkgs.stdenv.isLinux {
      # keep-sorted start
      blast = callPackage (byNamePackage "blast") {};
      viennarna-hpc = callPackage (byNamePackage "viennarna-hpc") {};
      # keep-sorted end
    };

  externalPackages = {
    # keep-sorted start
    selexqc = inputs.selexqc.packages.${system}.selexqc or null;
    seqtable = inputs.seqtable.packages.${system}.seqtable or null;
    # keep-sorted end
  };
in
  regularPackages
  // externalPackages
  // {
    # Python packages used as CLI
    inherit (python3PackagesExtended) cutadapt;

    # Python package sets
    python3Packages = python3PackagesExtended;

    python3 = pkgs.python3.override {
      packageOverrides = pythonOverlay;
    };

    python311 = pkgs.python311.override {
      packageOverrides = pythonOverlay;
    };

    python312 = pkgs.python312.override {
      packageOverrides = pythonOverlay;
    };

    python313 = pkgs.python313.override {
      packageOverrides = pythonOverlay;
    };

    python311Packages = pkgs.python311Packages.overrideScope pythonOverlay;
    python312Packages = pkgs.python312Packages.overrideScope pythonOverlay;
    python313Packages = pkgs.python313Packages.overrideScope pythonOverlay;
  }
