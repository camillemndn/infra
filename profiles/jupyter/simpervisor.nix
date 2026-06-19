{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
}:

buildPythonPackage rec {
  pname = "simpervisor";
  version = "1.0.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-frh8qG1eJ2l29bsCkJdaBdRSxqe39YBi2up9g2nII8E=";
  };

  build-system = [ hatchling ];

  pythonImportsCheck = [ "simpervisor" ];

  meta = {
    description = "Simple Python child process supervisor";
    homepage = "https://github.com/yuvipanda/simpervisor";
    license = lib.licenses.bsd3;
  };
}
