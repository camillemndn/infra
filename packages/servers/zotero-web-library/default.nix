{ lib
, buildNpmPackage
, fetchFromGitHub
, fetchurl
, rsync
, nodejs
}:

buildNpmPackage rec {
  pname = "zotero-web-library";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "zotero";
    repo = "web-library";
    rev = "v${version}";
    hash = "sha256-VuzoKzHVMHYqYhRo7Wdss+137fQEplPz7dYBP/l5BUY=";
  };

  patches = [ ./prepare.patch ./add-bin.patch ];

  npmDepsHash = "sha256-y3iMObQ7UUuQfgmuQtpHfnW4/RzWRrEO3dPwbiYMYYs=";

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
