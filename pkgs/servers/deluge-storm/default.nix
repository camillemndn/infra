{ lib
, fetchFromGitHub
, buildNpmPackage
, buildGoModule
}:

buildGoModule rec {
  pname = "deluge-storm";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "relvacode";
    repo = "storm";
    rev = "v${version}";
    hash = "sha256-xvBEnJvjWL/COWF0j4ynwva5ilE2NbjzMKslV1wcsCc=";
  };

  deluge-storm-frontend = buildNpmPackage {
    pname = "deluge-storm-frontend";

    inherit version src meta;

    sourceRoot = "source/frontend";

    npmDepsHash = "sha256-4335cCOdApcbBIneXlpI09q6Aq//V7cjRWYDro0SoQ8=";

    npmBuildScript = "build:prod";
  };

  vendorHash = "sha256-YsqWC5W1X6QJR4YSynYmhuz+0bY63VyWLdZNxlpGs84=";

  preBuild = ''
    cp -r ${deluge-storm-frontend}/lib/node_modules/storm/dist frontend
  '';

  postInstall = ''
    mv $out/bin/storm $out/bin/deluge-storm
  '';

  meta = with lib; {
    description = "A Modern Deluge Interface";
    homepage = "https://github.com/relvacode/storm";
    license = licenses.mit;
    maintainers = with maintainers; [ camillemndn ];
  };
}
