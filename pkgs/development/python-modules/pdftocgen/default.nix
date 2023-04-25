{ lib
, python3
, fetchPypi
, poetry
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pdf-tocgen";
  version = "1.3.0";
  format = "pyproject";

  src = fetchPypi {
    pname = "pdf.tocgen";
    inherit version;
    hash = "sha256-rSyxicLSPM9SLka6y90CKjfdFm3rRF5rTufLEqoc3Hg=";
  };

  nativeBuildInputs = [
    poetry
  ];

  propagatedBuildInputs = with python3.pkgs; [
    poetry-core
    pymupdf
    toml
  ];

  pythonImportsCheck = [ "pdftocgen" ];

  meta = with lib; {
    description = "Automatically generate table of contents for pdf files";
    homepage = "https://pypi.org/project/pdf.tocgen/";
    license = with licenses; [ agpl3Only gpl3Only ];
    maintainers = with maintainers; [ camillemndn ];
  };
}
