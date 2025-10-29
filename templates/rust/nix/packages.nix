{inputs, ...}: {
  perSystem = {
    lib,
    pkgs,
    self',
    ...
  }: {
    packages = {
      PROJ_NAME = pkgs.rustPlatform.buildRustPackage {
        pname = "PROJ_NAME";
        version = "0.1.0";

        src = inputs.gitignore.lib.gitignoreSource ../.;

        cargoLock.lockFile = ../Cargo.lock;

        nativeBuildInputs = with pkgs; [
          pkg-config
        ];

        meta = with lib; {
          description = "High-performance parallel FASTA/FASTQ sequence counter";
          homepage = "https://github.com/yourusername/PROJ_NAME";
          license = licenses.mit;
          maintainers = [];
          platforms = platforms.linux ++ platforms.darwin;
          mainProgram = "PROJ_NAME";
        };
      };

      default = self'.packages.PROJ_NAME;
    };
  };
}
