{ lib
, python3
, fetchPypi
, alsa-lib
}:

python3.pkgs.buildPythonPackage rec {
  pname = "pyalsaaudio";
  version = "0.9.2";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-50pm1semvM65kN9m0+vA/jgvyddl818FD52YxpUwSzY=";
  };

  buildInputs = [ alsa-lib ];

  doCheck = false;
  pythonImportsCheck = [ "alsaaudio" ];

  meta = with lib; {
    description = "ALSA bindings";
    homepage = "https://pypi.org/project/pyalsaaudio/";
    license = licenses.psfl;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.linux;
  };
}
