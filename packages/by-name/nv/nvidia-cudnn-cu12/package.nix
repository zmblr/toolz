{
  buildPythonPackage,
  fetchurl,
  lib,
  autoPatchelfHook,
  stdenv,
  nvidia-cublas-cu12,
  zlib,
}:
buildPythonPackage rec {
  pname = "nvidia-cudnn-cu12";
  version = "9.5.1.17";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/2a/78/4535c9c7f859a64781e43c969a3a7e84c54634e319a996d43ef32ce46f83/nvidia_cudnn_cu12-9.5.1.17-py3-none-manylinux_2_28_x86_64.whl";
    hash = "sha256-MKw4afbbF9Fw4OVW3WzF7uAmR6vDHKhWY01aQPgsFbI=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    zlib
  ];

  dependencies = [nvidia-cublas-cu12];

  # Remove namespace __init__.py to prevent collisions (PEP 420 implicit namespace)
  postInstall = ''
    rm -f $out/lib/python*/site-packages/nvidia/__init__.py
    rm -rf $out/lib/python*/site-packages/nvidia/__pycache__
  '';

  pythonImportsCheck = ["nvidia.cudnn"];

  meta = {
    description = "NVIDIA cuDNN deep learning library";
    homepage = "https://developer.nvidia.com/cudnn";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    maintainers = [];
  };
}
