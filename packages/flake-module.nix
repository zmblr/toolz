{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages =
      {
        bbtools = pkgs.callPackage ./bbtools.nix {};
        cutadapt = pkgs.callPackage ./cutadapt.nix {};
        dnaio = pkgs.callPackage ./dnaio.nix {};
        fastaptamer = pkgs.callPackage ./fastaptamer.nix {};
        flash = pkgs.callPackage ./flash.nix {};
        nextflow = pkgs.callPackage ./nextflow {};
        xopen = pkgs.callPackage ./xopen.nix {};
      }
      // lib.optionalAttrs pkgs.stdenv.isLinux {
        blast = pkgs.callPackage ./blast.nix {};
      };
  };
}
