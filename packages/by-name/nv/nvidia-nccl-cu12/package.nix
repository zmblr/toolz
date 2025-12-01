{
  buildPythonPackage,
  fetchurl,
  lib,
  autoPatchelfHook,
  stdenv,
}:
buildPythonPackage rec {
  pname = "nvidia-nccl-cu12";
  version = "2.23.4";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/ed/1f/6482380ec8dcec4894e7503490fc536d846b0d59694acad9cf99f27d0e7d/nvidia_nccl_cu12-2.23.4-py3-none-manylinux2014_x86_64.whl";
    hash = "sha256-sJcljZqrL6n2huM8b+QK5Xsn32DO29FdE5cBu1UJ4ME=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
  buildInputs = [(lib.getLib stdenv.cc.cc)];

  # Remove namespace __init__.py to prevent collisions (PEP 420 implicit namespace)
  postInstall = ''
    rm -f $out/lib/python*/site-packages/nvidia/__init__.py
    rm -rf $out/lib/python*/site-packages/nvidia/__pycache__
  '';

  pythonImportsCheck = ["nvidia.nccl"];

  meta = {
    description = "NVIDIA Collective Communication Library (NCCL)";
    homepage = "https://developer.nvidia.com/nccl";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    maintainers = [];
  };
}
