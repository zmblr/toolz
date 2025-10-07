{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages =
      {
        bbtools = pkgs.callPackage ./bbtools.nix {};
        fastaptamer = pkgs.callPackage ./fastaptamer.nix {};
      }
      // lib.optionalAttrs pkgs.stdenv.isLinux {
        blast = pkgs.callPackage ./blast.nix {};
      };
  };
}
