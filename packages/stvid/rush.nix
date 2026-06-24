{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  attrs,
}:
buildPythonPackage rec {
  pname = "rush";
  version = "2021.4.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-gYYkB18DE/ZKTDi6YrxKZSbuMbRjmQyK6/A6mPWq8mQ=";
  };

  build-system = [ setuptools ];

  # redis/rfc3986 are optional extras; only attrs is required at runtime.
  dependencies = [ attrs ];

  pythonImportsCheck = [ "rush" ];

  meta = with lib; {
    description = "A library for throttling and rate limiting";
    homepage = "https://github.com/sigmavirus24/rush";
    license = licenses.mit;
  };
}
