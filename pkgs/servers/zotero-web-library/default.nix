{ lib
, buildNpmPackage
, fetchFromGitHub
, rsync
}:

buildNpmPackage rec {
  pname = "zotero-web-library";
  version = "1.3.12";

  src = fetchFromGitHub {
    owner = "zotero";
    repo = "web-library";
    rev = "v${version}";
    hash = "sha256-+9K1K7YcIzfCwY8Fdnh1UU1Hy1/76Iaglwnv6FcPNHw=";
  };

  patches = [ ./prepare.patch ./add-bin.patch ];

  npmDepsHash = "sha256-13vin1+gkkCUPbylWcBljQn4098GRH/V/vsV1AYduYg=";

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
