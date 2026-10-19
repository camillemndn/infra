{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonPackage rec {
  build-system = with python3.pkgs; [
    poetry-core
  ];

  meta = {
    description = "Minimal, super readable string pattern matching";
    homepage = "https://pypi.org/project/simplematch/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ camillemndn ];
  };

  pname = "simplematch";
  pyproject = true;

  pythonImportsCheck = [
    "simplematch"
  ];

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-VadyeLPQaGyzjj/+WjJqX1nCmV8bofoaT2iHLBfK9Ms=";
  };

  version = "1.4";
}
