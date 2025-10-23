{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages = import ./lib/make-packages.nix {
      inherit lib;
      inherit (pkgs) callPackage stdenv;
    };
  };
}
