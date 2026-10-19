{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  build-system = [
    python3.pkgs.poetry-core
  ];

  dependencies = with python3.pkgs; [
    chardet
    pymupdf
    toml
  ];

  meta = {
    description = "Automatically generate table of contents for pdf files";
    homepage = "https://pypi.org/project/pdf.tocgen/";

    license = with lib.licenses; [
      agpl3Only
      gpl3Only
    ];

    mainProgram = "pdf-tocgen";
    maintainers = with lib.maintainers; [ camillemndn ];
  };

  pname = "pdftocgen";
  pyproject = true;

  pythonImportsCheck = [
    "pdftocgen"
  ];

  src = fetchPypi {
    inherit version;
    hash = "sha256-CQdYgyYUcn6vH9C6AHXVoQ648mjR1TT6vXExFwqKx54=";
    pname = "pdf_tocgen";
  };

  version = "1.3.4";
}
