{
  buildPythonPackage,
  fetchurl,
  lib,
  autoPatchelfHook,
  stdenv,
}:
buildPythonPackage rec {
  pname = "nvidia-cublas-cu12";
  version = "12.6.3.3";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/f3/e7/c186a31c234fce776436753bfef4807df7f9b4cb3eeff358fcfcbf64b547/nvidia_cublas_cu12-12.6.3.3-py3-none-manylinux2014_x86_64.whl";
    hash = "sha256-8z+2jhAdmUcMgtF/kqDdn3TeKiFoXCF/RxbN1jsTFus=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
  buildInputs = [(lib.getLib stdenv.cc.cc)];

  # Remove namespace __init__.py to prevent collisions (PEP 420 implicit namespace)
  postInstall = ''
    rm -f $out/lib/python*/site-packages/nvidia/__init__.py
    rm -rf $out/lib/python*/site-packages/nvidia/__pycache__
  '';

  pythonImportsCheck = ["nvidia.cublas"];

  meta = {
    description = "CUBLAS native runtime libraries";
    homepage = "https://developer.nvidia.com/cublas";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    maintainers = [];
  };
}
