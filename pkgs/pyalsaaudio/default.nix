{
  lib,
  python3,
  fetchPypi,
  alsa-lib,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "pyalsaaudio";
  version = "0.11.0";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-p4qdyjNSSyyQZLNOIfWrh0JyMTzzJKmndZLzlqXg/dw=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  buildInputs = [ alsa-lib ];

  pythonImportsCheck = [
    "alsaaudio"
  ];

  meta = {
    description = "ALSA bindings";
    homepage = "https://pypi.org/project/pyalsaaudio/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ camillemndn ];
  };
}
