{
  buildPythonPackage,
  fetchurl,
  lib,
  autoPatchelfHook,
  stdenv,
}:
buildPythonPackage rec {
  pname = "nvidia-cuda-nvcc-cu12";
  version = "12.6.77";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/62/8f/cd3032281ba7bb531fe3159337af00c5c805fd6a31dc700f0715c8748c8c/nvidia_cuda_nvcc_cu12-12.6.77-py3-none-manylinux2014_x86_64.whl";
    hash = "sha256-tmu13WuK5iJiWGaRl307SkJekdthtLm8L2tCvNQVS5Y=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
  buildInputs = [(lib.getLib stdenv.cc.cc)];

  # Remove namespace __init__.py to prevent collisions (PEP 420 implicit namespace)
  postInstall = ''
    rm -f $out/lib/python*/site-packages/nvidia/__init__.py
    rm -rf $out/lib/python*/site-packages/nvidia/__pycache__
  '';

  pythonImportsCheck = ["nvidia.cuda_nvcc"];

  meta = {
    description = "CUDA compiler driver";
    homepage = "https://developer.nvidia.com/cuda-toolkit";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    maintainers = [];
  };
}
