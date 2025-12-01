{
  buildPythonPackage,
  fetchurl,
  lib,
  autoPatchelfHook,
  stdenv,
  jax,
}:
buildPythonPackage rec {
  pname = "jax-cuda12-pjrt";
  version = "0.4.34";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/2c/96/6c7162d57d13bf14cd2e70780c583bf5056e7cbc21a07ade6397ac80b3d4/jax_cuda12_pjrt-0.4.34-py3-none-manylinux2014_x86_64.whl";
    hash = "sha256-DHzJj5Ysx/yOCl6mMxtCoM7lFvIC8cMBn2qlzZUwzKA=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
  buildInputs = [(lib.getLib stdenv.cc.cc)];

  dependencies = [jax];

  pythonImportsCheck = ["jax_plugins.xla_cuda12"];

  meta = {
    description = "JAX XLA PJRT Plugin for CUDA 12";
    homepage = "https://github.com/google/jax";
    license = lib.licenses.asl20;
    platforms = ["x86_64-linux"];
    maintainers = [];
  };
}
