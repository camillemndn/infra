{ lib
, buildNpmPackage
, fetchFromGitHub
, rsync
}:

buildNpmPackage rec {
  pname = "zotero-web-library";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "zotero";
    repo = "web-library";
    rev = "v${version}";
    hash = "sha256-4hnxI67Ich/FV1vNf1kqO/zYHLV/bG7LvEe2XbQIQCU=";
  };

  patches = [ ./prepare.patch ./add-bin.patch ];

  npmDepsHash = "sha256-vO0VLIZPjEo6cyOQ+CnDGns8Ej6v2W3y2TIzeB0B8P4=";

  nativeBuildInputs = [ rsync ];

  npmBuildScript = "build:all";

  postBuild = ''
    npm run build:postprocess
  '';

  npmInstallFlags = [ "--include dev" ];

  npmPackFlags = [ "--ignore-scripts" ];

  meta = with lib; {
    description = "The official web-based client to access the Zotero API.";
    homepage = "https://github.com/zotero/web-library";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.linux;
  };
}
