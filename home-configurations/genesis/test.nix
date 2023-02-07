{ lib
, python3
, fetchFromGitHub
, python3Packages
}:

python3.pkgs.buildPythonApplication rec {
  pname = "qpageview";
  version = "0.6.2";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "frescobaldi";
    repo = "qpageview";
    rev = "v${version}";
    hash = "sha256-XFMTOD7ums8sbFHUViEI9q6/rCjUmEtXAdd3/OmLsHU=";
  };

  propagatedBuildInputs = with python3Packages; [ pyqt5 ];

  pythonImportsCheck = [ "qpageview" ];

  meta = with lib; {
    description = "page-based viewer widget for Qt5/PyQt5";
    homepage = "https://github.com/frescobaldi/qpageview";
    changelog = "https://github.com/frescobaldi/qpageview/blob/${src.rev}/ChangeLog";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
