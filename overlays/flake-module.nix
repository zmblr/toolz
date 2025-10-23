{self, ...}: {
  flake.overlays.default = _final: prev: let
    regularPackages = import (self + "/packages/lib/make-packages.nix") {
      inherit (prev) lib callPackage stdenv;
    };

    # Python packages override
    pythonPackagesOverride = import (self + "/packages/top-level/python-packages.nix");
  in
    regularPackages
    // {
      python3 = prev.python3.override {
        packageOverrides = pythonPackagesOverride;
      };

      python311 = prev.python311.override {
        packageOverrides = pythonPackagesOverride;
      };

      python312 = prev.python312.override {
        packageOverrides = pythonPackagesOverride;
      };

      python313 = prev.python313.override {
        packageOverrides = pythonPackagesOverride;
      };

      python3Packages = prev.python3Packages.overrideScope pythonPackagesOverride;

      python311Packages = prev.python311Packages.overrideScope pythonPackagesOverride;

      python312Packages = prev.python312Packages.overrideScope pythonPackagesOverride;

      python313Packages = prev.python313Packages.overrideScope pythonPackagesOverride;
    };
}
