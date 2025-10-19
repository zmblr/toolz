{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages =
      {
        # keep-sorted start
        aptasuite = pkgs.callPackage ./aptasuite.nix {};
        bbtools = pkgs.callPackage ./bbtools.nix {};
        cutadapt = pkgs.callPackage ./cutadapt.nix {};
        dnaio = pkgs.callPackage ./dnaio.nix {};
        fastaptamer = pkgs.callPackage ./fastaptamer.nix {};
        flash = pkgs.callPackage ./flash.nix {};
        jellyfish = pkgs.callPackage ./jellyfish.nix {};
        jellyfish-full = pkgs.callPackage ./jellyfish-full.nix {};
        nextflow = pkgs.callPackage ./nextflow {};
        xopen = pkgs.callPackage ./xopen.nix {};
        # keep-sorted end
      }
      // lib.optionalAttrs pkgs.stdenv.isLinux {
        blast = pkgs.callPackage ./blast.nix {};
      };
  };
}
