# Python packages from toolz flake
# This file defines Python packages in the python3Packages namespace
# Following nixpkgs conventions
self: _super:
with self; {
  # Bioinfo Python packages
  # keep-sorted start

  cutadapt = callPackage ../../by-name/cu/cutadapt/package.nix {};
  dnaio = callPackage ../../by-name/dn/dnaio/package.nix {};
  forgi = callPackage ../../by-name/fo/forgi/package.nix {};
  logging_exceptions = callPackage ../../by-name/lo/logging-exceptions/package.nix {};
  xopen = callPackage ../../by-name/xo/xopen/package.nix {};
  # keep-sorted end

  # ViennaRNA HPC with Python bindings (Linux only)
  # This wraps the full viennarna-hpc package to expose Python bindings
  viennarna-hpc = lib.optionalAttrs pkgs.stdenv.isLinux (
    toPythonModule (pkgs.viennarna-hpc.override {python3 = self.python;})
  );
}
