{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  # Build dependencies
  setuptools,
  setuptools-scm,
  # Runtime dependencies
  absl-py,
  jax,
  jaxlib,
  jax-cuda12-plugin,
  triton,
  # Test dependencies
  pytestCheckHook,
}:
buildPythonPackage rec {
  pname = "jax-triton";
  version = "0.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jax-ml";
    repo = "jax-triton";
    rev = "v${version}";
    hash = "sha256-1zqCYA/iGKt2GQvGywwT+56GnGgvxh8RR99RRpDjvYg=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    absl-py
    jax
    jaxlib
    jax-cuda12-plugin
    triton
  ];

  # Set version for setuptools-scm since we're not using git
  env.SETUPTOOLS_SCM_PRETEND_VERSION = version;

  # Skip import check - requires GPU at build time
  # pythonImportsCheck = ["jax_triton"];

  # Tests require GPU
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  meta = {
    description = "JAX + OpenAI Triton integration";
    longDescription = ''
      jax-triton provides integration between JAX and OpenAI's Triton,
      a language and compiler for parallel programming on GPUs.

      This enables writing custom GPU kernels in Triton and using them
      seamlessly in JAX programs.
    '';
    homepage = "https://github.com/jax-ml/jax-triton";
    changelog = "https://github.com/jax-ml/jax-triton/releases/tag/v${version}";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
  };
}
