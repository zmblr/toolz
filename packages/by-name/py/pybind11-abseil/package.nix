{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  abseil-cpp,
  pybind11,
  python3,
}:
stdenv.mkDerivation (_finalAttrs: {
  pname = "pybind11-abseil";
  version = "unstable-2024-08-07";

  src = fetchFromGitHub {
    owner = "pybind";
    repo = "pybind11_abseil";
    rev = "bddf30141f9fec8e577f515313caec45f559d319";
    hash = "sha256-9Trl4uwUhXWNTD3pH3cgIfkSRgb2c60TmSk9WL7IjSQ=";
  };

  nativeBuildInputs = [
    cmake
    stdenv.cc # For patchelf in postFixup
  ];

  buildInputs = [
    abseil-cpp
    pybind11
    python3
  ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=17"
    "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
    "-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF"
    "-DABSL_PROPAGATE_CXX_STD=ON"
    "-DBUILD_TESTING=OFF"
  ];

  # Provide pre-fetched dependencies to avoid FetchContent downloads
  postPatch = ''
        # Replace FetchContent with find_package for system dependencies
        substituteInPlace CMakeLists.txt \
          --replace-fail "FetchContent_Declare(
      abseil-cpp
      URL https://github.com/abseil/abseil-cpp/archive/refs/tags/20230802.0.tar.gz
      URL_HASH
        SHA256=59d2976af9d6ecf001a81a35749a6e551a335b949d34918cfade07737b9d93c5)

    FetchContent_Declare(
      pybind11
      URL https://github.com/pybind/pybind11/archive/refs/heads/master.tar.gz)

    FetchContent_MakeAvailable(abseil-cpp pybind11)" "# Use system packages
    find_package(absl REQUIRED)
    find_package(pybind11 REQUIRED)"
  '';

  # No install target in CMakeLists.txt, manually install headers and libraries
  installPhase = ''
    runHook preInstall

    # Install headers (main purpose of this library)
    mkdir -p $out/include
    cp -r $src/pybind11_abseil $out/include/

    # Install static libraries and core shared libraries (exclude test/example binaries)
    mkdir -p $out/lib
    find pybind11_abseil -name '*.a' -exec cp {} $out/lib/ \;

    # Only install core shared libraries (ok_status_singleton.so, status.so)
    # Exclude test binaries (*_example.so, *_testing.so, missing_import.so)
    cp pybind11_abseil/ok_status_singleton.so $out/lib/ || true
    cp pybind11_abseil/status.so $out/lib/ || true

    runHook postInstall
  '';

  meta = {
    description = "Pybind11 bindings for the Abseil C++ Common Libraries";
    homepage = "https://github.com/pybind/pybind11_abseil";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
  };
})
