{
  self,
  inputs,
  ...
}: {
  flake.overlays.default = _final: prev: let
    pythonOverlay = import (self + "/packages/lib/make-python-packages.nix") {
      inherit (prev) lib callPackage stdenv;
      inherit inputs;
      inherit (prev) system;
    };

    python3PackagesExtended = prev.python3Packages.overrideScope pythonOverlay;

    regularPackages = import (self + "/packages/lib/make-packages.nix") {
      inherit (prev) lib callPackage stdenv;
      inherit inputs;
      inherit (prev) system;
      python3Packages = python3PackagesExtended;
    };
  in
    regularPackages
    // {
      python3 = prev.python3.override {
        packageOverrides = pythonOverlay;
      };

      python311 = prev.python311.override {
        packageOverrides = pythonOverlay;
      };

      python312 = prev.python312.override {
        packageOverrides = pythonOverlay;
      };

      python313 = prev.python313.override {
        packageOverrides = pythonOverlay;
      };

      python3Packages = python3PackagesExtended;

      python311Packages = prev.python311Packages.overrideScope pythonOverlay;

      python312Packages = prev.python312Packages.overrideScope pythonOverlay;

      python313Packages = prev.python313Packages.overrideScope pythonOverlay;
    };
}
