{
  buildPythonPackage,
  fetchurl,
  lib,
  autoPatchelfHook,
  stdenv,
}:
buildPythonPackage rec {
  pname = "nvidia-nvjitlink-cu12";
  version = "12.6.77";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/fe/e4/486de766851d58699bcfeb3ba6a3beb4d89c3809f75b9d423b9508a8760f/nvidia_nvjitlink_cu12-12.6.77-py3-none-manylinux2014_x86_64.whl";
    hash = "sha256-muNG0WIDrk6lE75BZJUWegEB0z0tFJNaqcGCmj+0UUI=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
  buildInputs = [(lib.getLib stdenv.cc.cc)];

  # Remove namespace __init__.py to prevent collisions (PEP 420 implicit namespace)
  postInstall = ''
    rm -f $out/lib/python*/site-packages/nvidia/__init__.py
    rm -rf $out/lib/python*/site-packages/nvidia/__pycache__
  '';

  pythonImportsCheck = ["nvidia.nvjitlink"];

  meta = {
    description = "NVIDIA JIT LTO Library";
    homepage = "https://developer.nvidia.com/cuda-toolkit";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    maintainers = [];
  };
}
