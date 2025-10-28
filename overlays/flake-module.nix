{
  self,
  inputs,
  ...
}: {
  flake.overlays.default = _final: prev:
    import (self + "/packages/lib/all-packages.nix") {
      pkgs = prev;
      inherit inputs;
      inherit (prev) system;
    };
}
