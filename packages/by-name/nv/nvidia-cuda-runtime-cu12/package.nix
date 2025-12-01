{
  buildPythonPackage,
  fetchurl,
  lib,
  autoPatchelfHook,
  stdenv,
}:
buildPythonPackage rec {
  pname = "nvidia-cuda-runtime-cu12";
  version = "12.6.77";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/e1/23/e717c5ac26d26cf39a27fbc076240fad2e3b817e5889d671b67f4f9f49c5/nvidia_cuda_runtime_cu12-12.6.77-py3-none-manylinux2014_x86_64.manylinux_2_17_x86_64.whl";
    hash = "sha256-ujtWpPiWFB4l4Zqyh81x5SpqD0sp0NMWCfYOO01SGbc=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
  buildInputs = [(lib.getLib stdenv.cc.cc)];

  # Remove namespace __init__.py to prevent collisions (PEP 420 implicit namespace)
  postInstall = ''
    rm -f $out/lib/python*/site-packages/nvidia/__init__.py
    rm -rf $out/lib/python*/site-packages/nvidia/__pycache__
  '';

  pythonImportsCheck = ["nvidia.cuda_runtime"];

  meta = {
    description = "CUDA Runtime native Libraries";
    homepage = "https://developer.nvidia.com/cuda-toolkit";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    maintainers = [];
  };
}
