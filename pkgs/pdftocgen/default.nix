{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pdftocgen";
  version = "1.3.4";
  pyproject = true;

  src = fetchPypi {
    pname = "pdf_tocgen";
    inherit version;
    hash = "sha256-CQdYgyYUcn6vH9C6AHXVoQ648mjR1TT6vXExFwqKx54=";
  };

  build-system = [
    python3.pkgs.poetry-core
  ];

  dependencies = with python3.pkgs; [
    chardet
    pymupdf
    toml
  ];

  pythonImportsCheck = [
    "pdftocgen"
  ];

  meta = {
    description = "Automatically generate table of contents for pdf files";
    homepage = "https://pypi.org/project/pdf.tocgen/";
    license = with lib.licenses; [
      agpl3Only
      gpl3Only
    ];
    maintainers = with lib.maintainers; [ camillemndn ];
    mainProgram = "pdf-tocgen";
  };
}
