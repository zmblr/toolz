{
  buildPythonPackage,
  fetchurl,
  lib,
  autoPatchelfHook,
  stdenv,
}:
buildPythonPackage rec {
  pname = "nvidia-cufft-cu12";
  version = "11.3.0.4";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/8f/16/73727675941ab8e6ffd86ca3a4b7b47065edcca7a997920b831f8147c99d/nvidia_cufft_cu12-11.3.0.4-py3-none-manylinux2014_x86_64.manylinux_2_17_x86_64.whl";
    hash = "sha256-zLpi65zvVVmr1eDVTO7S2ZNAMPURY98BhTIUKo7FM+U=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
  buildInputs = [(lib.getLib stdenv.cc.cc)];

  # Remove namespace __init__.py to prevent collisions (PEP 420 implicit namespace)
  postInstall = ''
    rm -f $out/lib/python*/site-packages/nvidia/__init__.py
    rm -rf $out/lib/python*/site-packages/nvidia/__pycache__
  '';

  pythonImportsCheck = ["nvidia.cufft"];

  meta = {
    description = "CUFFT native runtime libraries";
    homepage = "https://developer.nvidia.com/cufft";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    maintainers = [];
  };
}
