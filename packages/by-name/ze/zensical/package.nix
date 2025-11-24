{
  lib,
  buildPythonPackage,
  fetchPypi,
  cargo,
  rustPlatform,
  rustc,
  libiconv,
  darwin,
  stdenv,
  # Python dependencies
  click,
  deepmerge,
  markdown,
  pygments,
  pymdown-extensions,
  pyyaml,
  tomli,
}:
buildPythonPackage rec {
  pname = "zensical";
  version = "0.0.9";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-W0Hi3dLxlpTm+muwIahQlaCfe9Cvt+pKtpTnPc3D2JI=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-n5PL2FhWKf7+TDcuQG8/xwViVXGcILdu60MXMbr3KUE=";
  };

  nativeBuildInputs = [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin (
    with darwin.apple_sdk.frameworks; [
      libiconv
      Security
      SystemConfiguration
    ]
  );

  propagatedBuildInputs = [
    click
    deepmerge
    markdown
    pygments
    pymdown-extensions
    pyyaml
    tomli
  ];

  # Skip runtime dependency version check
  # pymdown-extensions in nixpkgs is 10.14.3, but zensical requires >=10.15
  # This is a minor version difference and should work fine
  dontCheckRuntimeDeps = true;

  pythonImportsCheck = ["zensical"];

  meta = with lib; {
    description = "A modern static site generator built by the creators of Material for MkDocs";
    homepage = "https://zensical.org/";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.unix;
  };
}
