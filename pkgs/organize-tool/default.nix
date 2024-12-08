{
  lib,
  python3,
  fetchPypi,
  makeWrapper,
  exiftool,
  simplematch,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "organize-tool";
  version = "3.3.0";
  pyproject = true;

  src = fetchPypi {
    pname = "organize_tool";
    inherit version;
    hash = "sha256-A0/c+f/rI9IbSV4DhmUnjlifoE3HwMCgGko7MKBsU58=";
  };

  postPatch = ''
    sed -i pyproject.toml -e 's/ExifRead = .*/ExifRead = "^3.0.0"/'
  '';

  build-system = [
    python3.pkgs.poetry-core
  ];

  nativeBuildInputs = [ makeWrapper ];

  dependencies = with python3.pkgs; [
    arrow
    docopt-ng
    docx2txt
    exifread
    jinja2
    natsort
    pdfminer-six
    platformdirs
    pydantic
    pyyaml
    rich
    send2trash
    simplematch
  ];

  optional-dependencies = with python3.pkgs; {
    docs = [
      markupsafe
      mkdocs
      mkdocs-autorefs
      mkdocs-include-markdown-plugin
      mkdocstrings
    ];
  };

  pythonImportsCheck = [
    "organize"
  ];

  postFixup = ''
    wrapProgram $out/bin/organize \
      --set ORGANIZE_EXIFTOOL_PATH ${exiftool}/bin/exiftool
  '';

  meta = {
    description = "The file management automation tool";
    homepage = "https://pypi.org/project/organize-tool/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ camillemndn ];
    mainProgram = "organize-tool";
  };
}
