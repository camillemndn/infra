{ lib
, buildNpmPackage
, fetchFromGitHub
, nodejs-16_x
}:

(buildNpmPackage.override { nodejs = nodejs-16_x; }) rec {
  pname = "overleaf";
  version = "unstable-2023-02-11";

  #sourceRoot = "source/services/web";

  patches = [ ./package-lock.patch ];

  #postPatch = ''
  #  grep urun ./package-lock.json
  #${nodejs-16_x}/bin/npm ci -loglevel=verbose --package-lock-only --ignore-scripts
  #'';

  preConfig = ''
    ls -all
    cp zeifzofez
  '';

  makeCacheWritable = true;

  npmDepsHash = "sha256-wrTp6bfcKJgHwkYToXunTYRNGnfMaKHwjGv7mXQXsLU=";

  npmFlags = [ "legacy-peer-deps" ];

  src = fetchFromGitHub {
    owner = "overleaf";
    repo = "overleaf";
    rev = "b0bd070018d181696092dec3d4431181aad17b01";
    hash = "sha256-PazUG3qcc9Utu6pYjppXe5A2N6pqZ+D42o7BDLzyJfQ=";
  };

  nativeBuildInputs = [ nodejs-16_x ];

  npmInstallFlags = [ ];

  npmRebuildFlags = [ ];

  preBuild = ''
    export NODE_OPTIONS=--openssl-legacy-provider
  '';

  npmBuildScript = "webpack:production";

  installPhase = ''
    cd dist
    ls -all
    mkdir $out
    cp -r * $out
  '';

  meta = with lib; {
    description = "A web-based collaborative LaTeX editor";
    homepage = "https://github.com/overleaf/overleaf/tree/main/services/web";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ];
  };
}
