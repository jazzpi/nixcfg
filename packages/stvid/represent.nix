{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:
buildPythonPackage rec {
  pname = "represent";
  version = "2.1";
  pyproject = true;

  src = fetchPypi {
    pname = "Represent";
    inherit version;
    hash = "sha256-Cy0BXBTnums7Xmp7oTGpUgE/6UQzmsU4dkznKKddvKw=";
  };

  build-system = [ setuptools ];

  # No runtime dependencies (only docs/test extras).
  pythonImportsCheck = [ "represent" ];

  meta = with lib; {
    description = "Create __repr__ and pretty printing helpers for Python classes";
    homepage = "https://github.com/RazerM/represent";
    license = licenses.mit;
  };
}
