{
  buildPythonPackage,
  fetchurl,
  lib,
  autoPatchelfHook,
  stdenv,
}:
buildPythonPackage rec {
  pname = "nvidia-cuda-cupti-cu12";
  version = "12.6.80";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/49/60/7b6497946d74bcf1de852a21824d63baad12cd417db4195fc1bfe59db953/nvidia_cuda_cupti_cu12-12.6.80-py3-none-manylinux2014_x86_64.manylinux_2_17_x86_64.whl";
    hash = "sha256-Z2i61sq08Z6CkhJeXxrIqn0XGHBAEqDjJypvYcS84TI=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
  buildInputs = [(lib.getLib stdenv.cc.cc)];

  # Remove namespace __init__.py to prevent collisions (PEP 420 implicit namespace)
  postInstall = ''
    rm -f $out/lib/python*/site-packages/nvidia/__init__.py
    rm -rf $out/lib/python*/site-packages/nvidia/__pycache__
  '';

  pythonImportsCheck = ["nvidia.cuda_cupti"];

  meta = {
    description = "CUDA Profiling Tools Interface";
    homepage = "https://developer.nvidia.com/cuda-toolkit";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    maintainers = [];
  };
}
