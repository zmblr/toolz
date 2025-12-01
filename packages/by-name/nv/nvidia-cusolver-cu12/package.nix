{
  buildPythonPackage,
  fetchurl,
  lib,
  autoPatchelfHook,
  stdenv,
  nvidia-cublas-cu12,
  nvidia-cusparse-cu12,
  nvidia-nvjitlink-cu12,
}:
buildPythonPackage rec {
  pname = "nvidia-cusolver-cu12";
  version = "11.7.1.2";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/f0/6e/c2cf12c9ff8b872e92b4a5740701e51ff17689c4d726fca91875b07f655d/nvidia_cusolver_cu12-11.7.1.2-py3-none-manylinux2014_x86_64.manylinux_2_17_x86_64.whl";
    hash = "sha256-6eSYQ6dwfkICK6u5vPozwphXqTuIAgxORDRlamVbaYw=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    nvidia-cublas-cu12
    nvidia-cusparse-cu12
    nvidia-nvjitlink-cu12
  ];

  dependencies = [
    nvidia-cublas-cu12
    nvidia-cusparse-cu12
    nvidia-nvjitlink-cu12
  ];

  # Remove namespace __init__.py to prevent collisions (PEP 420 implicit namespace)
  postInstall = ''
    rm -f $out/lib/python*/site-packages/nvidia/__init__.py
    rm -rf $out/lib/python*/site-packages/nvidia/__pycache__
  '';

  # autoPatchelfHook needs to find NVIDIA libraries in nested site-packages directories
  postFixup = ''
    addAutoPatchelfSearchPath "${nvidia-cublas-cu12}/${nvidia-cublas-cu12.pythonModule.sitePackages}/nvidia/cublas/lib"
    addAutoPatchelfSearchPath "${nvidia-cusparse-cu12}/${nvidia-cusparse-cu12.pythonModule.sitePackages}/nvidia/cusparse/lib"
    addAutoPatchelfSearchPath "${nvidia-nvjitlink-cu12}/${nvidia-nvjitlink-cu12.pythonModule.sitePackages}/nvidia/nvjitlink/lib"
  '';

  pythonImportsCheck = ["nvidia.cusolver"];

  meta = {
    description = "CUSOLVER native runtime libraries";
    homepage = "https://developer.nvidia.com/cusolver";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    maintainers = [];
  };
}
