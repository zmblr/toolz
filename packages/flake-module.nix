{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages =
      rec {
        # keep-sorted start
        aptasuite = pkgs.callPackage ./aptasuite.nix {};
        bbtools = pkgs.callPackage ./bbtools.nix {};
        cutadapt = pkgs.callPackage ./cutadapt.nix {};
        dnaio = pkgs.callPackage ./dnaio.nix {};
        fastaptamer = pkgs.callPackage ./fastaptamer.nix {};
        flash = pkgs.callPackage ./flash.nix {};
        forgi = pkgs.python3Packages.callPackage ./forgi.nix {inherit logging_exceptions;};
        jellyfish = pkgs.callPackage ./jellyfish.nix {};
        jellyfish-full = pkgs.callPackage ./jellyfish-full.nix {};
        kmc = pkgs.callPackage ./kmc.nix {};
        kmc-full = pkgs.callPackage ./kmc-full.nix {};
        logging_exceptions = pkgs.python3Packages.callPackage ./logging-exceptions.nix {};
        nextflow = pkgs.callPackage ./nextflow {};
        xopen = pkgs.callPackage ./xopen.nix {};
        # keep-sorted end
      }
      // lib.optionalAttrs pkgs.stdenv.isLinux {
        blast = pkgs.callPackage ./blast.nix {};
        viennarna-hpc = pkgs.callPackage ./viennarna-hpc.nix {};
      };
  };
}
