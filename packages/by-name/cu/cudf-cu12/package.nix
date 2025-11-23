{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  autoPatchelfHook,
  addDriverRunpath,
  stdenv,
  cudaPackages_12,
  cuda-compat,
  pylibcudf-cu12,
  libcudf-cu12,
  rmm-cu12,
  cachetools,
  cuda-core,
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
    dist = "cp312";
    python = "cp312";
    abi = "cp312";
    platform = "manylinux_2_24_x86_64.manylinux_2_28_x86_64";
    hash = "sha256-M/toJDG5zYEsmAutjW5qvAcYLo7YxmWm+q2SuprZ89w=";
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
    rmm-cu12
    # Python packages
    cachetools
    cuda-core
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
