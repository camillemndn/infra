{ lib
, python3
, fetchPypi
, poetry
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pdf-tocgen";
  version = "1.3.4";
  format = "pyproject";

  src = fetchPypi {
    pname = "pdf_tocgen";
    inherit version;
    hash = "sha256-CQdYgyYUcn6vH9C6AHXVoQ648mjR1TT6vXExFwqKx54=";
  };

  nativeBuildInputs = [
    poetry
  ];

  propagatedBuildInputs = with python3.pkgs; [
    poetry-core
    pymupdf
    toml
    chardet
  ];

  pythonImportsCheck = [ "pdftocgen" ];

  meta = with lib; {
    description = "Automatically generate table of contents for pdf files";
    homepage = "https://pypi.org/project/pdf.tocgen/";
    license = with licenses; [ agpl3Only gpl3Only ];
    maintainers = with maintainers; [ camillemndn ];
  };
}
