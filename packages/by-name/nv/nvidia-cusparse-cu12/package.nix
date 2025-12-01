{
  buildPythonPackage,
  fetchurl,
  lib,
  autoPatchelfHook,
  stdenv,
  nvidia-nvjitlink-cu12,
}:
buildPythonPackage rec {
  pname = "nvidia-cusparse-cu12";
  version = "12.5.4.2";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/06/1e/b8b7c2f4099a37b96af5c9bb158632ea9e5d9d27d7391d7eb8fc45236674/nvidia_cusparse_cu12-12.5.4.2-py3-none-manylinux2014_x86_64.manylinux_2_17_x86_64.whl";
    hash = "sha256-dVbZ7KFW4YGEuUlHreD7pbtH1pzsRr+GYP0scaS0i3M=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    nvidia-nvjitlink-cu12
  ];

  dependencies = [nvidia-nvjitlink-cu12];

  # Remove namespace __init__.py to prevent collisions (PEP 420 implicit namespace)
  postInstall = ''
    rm -f $out/lib/python*/site-packages/nvidia/__init__.py
    rm -rf $out/lib/python*/site-packages/nvidia/__pycache__
  '';

  # autoPatchelfHook needs to find libnvJitLink.so.12 in nested site-packages directory
  postFixup = ''
    addAutoPatchelfSearchPath "${nvidia-nvjitlink-cu12}/${nvidia-nvjitlink-cu12.pythonModule.sitePackages}/nvidia/nvjitlink/lib"
  '';

  pythonImportsCheck = ["nvidia.cusparse"];

  meta = {
    description = "CUSPARSE native runtime libraries";
    homepage = "https://developer.nvidia.com/cusparse";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux"];
    maintainers = [];
  };
}
