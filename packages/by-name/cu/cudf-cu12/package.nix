{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  autoPatchelfHook,
  addDriverRunpath,
  stdenv,
  # CUDA packages
  cudaPackages_12,
  cuda-compat,
  # RAPIDS dependencies
  pylibcudf-cu12,
  libcudf-cu12,
  # Python dependencies
  cachetools,
  cuda-python,
  cupy,
  fsspec,
  numba,
  numba-cuda,
  numpy,
  nvtx,
  packaging,
  pandas,
  pyarrow,
  rich,
  typing-extensions,
}:
buildPythonPackage rec {
  pname = "cudf-cu12";
  version = "25.10.0";
  format = "wheel";

  disabled = pythonOlder "3.10";

  src = fetchPypi {
    pname = "cudf_cu12";
    inherit version;
    format = "wheel";
    dist = "cp310";
    python = "cp310";
    abi = "cp310";
    platform = "manylinux_2_24_x86_64.manylinux_2_28_x86_64";
    hash = "sha256-Ew7x8NkMrjM1ZFSukqUVQNzXB0d5teHZWxovl50Uzfo=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    addDriverRunpath
  ];

  buildInputs = [
    libcudf-cu12
    stdenv.cc.cc.lib
    # CUDA Toolkit libraries for runtime
    cudaPackages_12.cuda_nvrtc
    cudaPackages_12.libnvjitlink
    cudaPackages_12.cuda_cudart
  ];

  # Propagate CUDA compatibility wrapper for runtime (cupy, numba dlopen)
  # Provides standard .so symlinks to Nix .alt.so CUDA libraries
  propagatedBuildInputs = [
    cuda-compat
  ];

  # Add libcudf lib64 directory to autoPatchelf search path
  preFixup = ''
    addAutoPatchelfSearchPath ${libcudf-cu12}/lib/python3.12/site-packages/libcudf/lib64
  '';

  dependencies = [
    # RAPIDS
    pylibcudf-cu12
    # Python packages
    cachetools
    cuda-python
    cupy
    fsspec
    numba
    numba-cuda
    numpy
    nvtx
    packaging
    pandas
    pyarrow
    rich
    typing-extensions
  ];

  # Skip tests - requires CUDA runtime
  doCheck = false;

  # Skip imports check - requires CUDA runtime
  # pythonImportsCheck = ["cudf"];

  meta = {
    description = "cuDF - GPU-accelerated DataFrame library (CUDA 12)";
    homepage = "https://github.com/rapidsai/cudf";
    license = lib.licenses.asl20;
    platforms = ["x86_64-linux" "aarch64-linux"];
    maintainers = [];
  };
}
