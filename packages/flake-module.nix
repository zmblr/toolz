{inputs, ...}: {
  perSystem = {
    system,
    pkgs,
    lib,
    ...
  }: let
    pythonOverlay = import ./lib/make-python-packages.nix {
      inherit lib inputs system;
      inherit (pkgs) callPackage stdenv;
    };

    python3PackagesExtended = pkgs.python3Packages.overrideScope pythonOverlay;
  in {
    packages = import ./lib/make-packages.nix {
      inherit lib inputs system;
      inherit (pkgs) callPackage stdenv;
      python3Packages = python3PackagesExtended;
    };

    legacyPackages = {
      python3Packages = python3PackagesExtended;
      python312Packages = pkgs.python312Packages.overrideScope pythonOverlay;
      python313Packages = pkgs.python313Packages.overrideScope pythonOverlay;
    };
  };
}
