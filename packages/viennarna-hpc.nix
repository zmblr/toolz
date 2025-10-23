{
  lib,
  stdenv,
  viennarna,
}:
viennarna.overrideAttrs (oldAttrs: {
  pname = "viennarna-hpc";

  # Enable SSE4.1 SIMD optimizations on x86_64
  configureFlags =
    oldAttrs.configureFlags
    ++ lib.optionals stdenv.isx86_64 [
      "--enable-sse" # ~2x faster multibranch loop decomposition
    ];

  # Aggressive optimization flags for high-performance computing
  NIX_CFLAGS_COMPILE = toString (
    lib.toList (oldAttrs.NIX_CFLAGS_COMPILE or "")
    ++ lib.optionals stdenv.isx86_64 [
      "-march=native" # CPU-specific optimizations
      "-O3" # Aggressive optimization
      "-mtune=native" # Tune for current CPU
    ]
  );

  meta =
    oldAttrs.meta
    // {
      description = "ViennaRNA Package (HPC Build with SSE4.1 SIMD)";
      longDescription = ''
        RNA secondary structure prediction and comparison with HPC optimizations.

        Performance enhancements over standard build:
        - SSE4.1 SIMD instructions: ~2x faster multibranch loop decomposition
        - Native CPU optimization: -march=native -mtune=native
        - Aggressive optimization: -O3
        - OpenMP parallel processing (enabled by default)
        - POSIX threads support (enabled by default)
        - Link-time optimization (enabled by default)

        Includes additional tools:
        - Cluster analysis: AnalyseSeqs, AnalyseDists
        - Kinwalker: co-transcriptional folding

        Python bindings are included and built via SWIG.
        To use with Python, wrap with toPythonModule:
          python3.withPackages (ps: [ (ps.toPythonModule viennarna-hpc) ])

        Note: Requires x86_64 CPU with SSE4.1 support
              (Intel Core 2008+, AMD Bulldozer 2011+)
      '';
      platforms = lib.platforms.unix;
      # Mark as broken on non-x86_64 since we use -march=native
      broken = !stdenv.isx86_64;
    };

  # Expose Python module creation helper in passthru
  passthru =
    (oldAttrs.passthru or {})
    // {
      # Helper function to create Python package
      # Usage: viennarna-hpc.pythonModule python3
      pythonModule = python:
        python.pkgs.toPythonModule (
          viennarna.overrideAttrs (_prevAttrs: {
            pname = "python-viennarna-hpc";
          })
        );
    };
})
