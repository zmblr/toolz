{
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShellNoCC {
      buildInputs = with pkgs; [
        nixVersions.latest
        gitMinimal
      ];
    };
  };
}
