{ lib
, python3
, fetchPypi
, alsa-lib
}:

python3.pkgs.buildPythonPackage rec {
  pname = "pyalsaaudio";
  version = "0.10.0";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-4hF1UAor0xCuOGfnmRY53vweKlySzxufcIMpazRnOKs=";
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
