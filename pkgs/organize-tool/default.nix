{
  lib,
  python3,
  fetchPypi,
  makeWrapper,
  exiftool,
  simplematch,
}:

python3.pkgs.buildPythonApplication rec {
  build-system = [
    python3.pkgs.poetry-core
  ];

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

  dontCheckRuntimeDeps = true;

  meta = {
    description = "The file management automation tool";
    homepage = "https://pypi.org/project/organize-tool/";
    license = lib.licenses.mit;
    mainProgram = "organize-tool";
    maintainers = with lib.maintainers; [ camillemndn ];
  };

  nativeBuildInputs = [ makeWrapper ];

  optional-dependencies = with python3.pkgs; {
    docs = [
      markupsafe
      mkdocs
      mkdocs-autorefs
      mkdocs-include-markdown-plugin
      mkdocstrings
    ];
  };

  pname = "organize-tool";

  postFixup = ''
    wrapProgram $out/bin/organize \
      --set ORGANIZE_EXIFTOOL_PATH ${exiftool}/bin/exiftool
  '';

  postPatch = ''
    sed -i pyproject.toml -e 's/ExifRead = .*/ExifRead = "^3.0.0"/'
  '';

  pyproject = true;

  pythonImportsCheck = [
    "organize"
  ];

  src = fetchPypi {
    inherit version;
    hash = "sha256-A0/c+f/rI9IbSV4DhmUnjlifoE3HwMCgGko7MKBsU58=";
    pname = "organize_tool";
  };

  version = "3.3.0";
}
