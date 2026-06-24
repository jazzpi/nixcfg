{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  # runtime deps
  filelock,
  httpx,
  logbook,
  outcome,
  platformdirs,
  represent,
  rush,
  sniffio,
  typing-extensions,
}:
buildPythonPackage rec {
  pname = "spacetrack";
  version = "1.4.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/ktUw97eBJag7MQDkhFIGiWuT70O/15UGQRB8NRDTHQ=";
  };

  build-system = [ setuptools ];

  dependencies = [
    filelock
    httpx
    logbook
    outcome
    platformdirs
    represent
    rush
    sniffio
    # logbook (a spacetrack dep) imports typing_extensions at runtime but does
    # not propagate it on Python 3.13; pull it in here so the env is complete.
    typing-extensions
  ];

  pythonImportsCheck = [ "spacetrack" ];

  meta = with lib; {
    description = "Python client for the space-track.org TLE/orbital data API";
    homepage = "https://github.com/python-astrodynamics/spacetrack";
    license = licenses.mit;
  };
}
