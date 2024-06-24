{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  buildGoModule,
}:

buildGoModule rec {
  pname = "deluge-storm";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "relvacode";
    repo = "storm";
    rev = "v${version}";
    hash = "sha256-7A8h3Qpqt4bVpSfafIpxG+CxodoT/F+VUGUdtyQt1m0=";
  };

  deluge-storm-frontend = buildNpmPackage {
    pname = "deluge-storm-frontend";

    inherit version src meta;

    sourceRoot = "source/frontend";

    npmDepsHash = "sha256-4335cCOdApcbBIneXlpI09q6Aq//V7cjRWYDro0SoQ8=";

    npmBuildScript = "build:prod";
  };

  vendorHash = "sha256-byxH1o+0rOkaUeB/oL1p/ela8opDo4cmh1AYLJ6YorU=";

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
