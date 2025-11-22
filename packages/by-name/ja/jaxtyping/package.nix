{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  typeguard,
}:
buildPythonPackage rec {
  pname = "jaxtyping";
  version = "0.2.34";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "patrick-kidger";
    repo = "jaxtyping";
    rev = "refs/tags/v${version}";
    hash = "sha256-zkB8/+0PmBKDFhj9dd8QZ5Euglm+W3BBUM4dwFUYYW8=";
  };

  build-system = [
    hatchling
  ];

  dependencies = [
    typeguard
  ];

  pythonImportsCheck = ["jaxtyping"];

  # Tests require JAX and other heavy dependencies
  doCheck = false;

  meta = {
    description = "Type annotations and runtime checking for shape and dtype of JAX arrays";
    homepage = "https://github.com/patrick-kidger/jaxtyping";
    license = lib.licenses.mit;
  };
}
