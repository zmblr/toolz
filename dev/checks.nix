{
  perSystem = {
    self',
    lib,
    ...
  }: let
    packages = lib.mapAttrs' (n: lib.nameValuePair "package-${n}") self'.packages;
    devShells = lib.mapAttrs' (n: lib.nameValuePair "devShell-${n}") self'.devShells;
  in {
    treefmt = {flakeCheck = true;};
    checks =
      {inherit (self') formatter;}
      // packages
      // devShells;
  };
}
