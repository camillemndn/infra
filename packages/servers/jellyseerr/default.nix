{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, mkYarnPackage
, nodejs
, nodePackages
, sqlite
, pkgs
, fetchYarnDeps
, python3
}:

let
  pin = lib.importJSON ./pin.json;
in

mkYarnPackage rec {
  pname = "jellyseerr";
  version = pin.version;

  src = fetchFromGitHub {
    owner = "Fallenbagel";
    repo = "jellyseerr";
    rev = "v${version}";
    sha256 = pin.srcSha256;
  };

  importJSON = ./package.json;

  offlineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    sha256 = pin.yarnSha256;
  };

  doDist = false;

  nativeBuildInputs = [
    nodejs
    makeWrapper
    sqlite
    python3
  ];

  # Fixes "SQLite package has not been found installed" at launch 
  pkgConfig.sqlite3.postInstall = ''
    export CPPFLAGS="-I${nodejs}/include/node"
    ${nodePackages.node-pre-gyp}/bin/node-pre-gyp install --prefer-offline --build-from-source --python=${python3}/bin/python --nodedir=${nodejs}/include/node
  '';

  pkgConfig.bcrypt.postInstall = ''
    export CPPFLAGS="-I${nodejs}/include/node"
    ${nodePackages.node-pre-gyp}/bin/node-pre-gyp install --prefer-offline --build-from-source --python=${python3}/bin/python --nodedir=${nodejs}/include/node
  '';

  buildPhase = ''
    runHook preBuild
    shopt -s dotglob
    pushd deps/jellyseerr
    rm -r config/*
    yarn build
    popd
    runHook postBuild
  '';

  postInstall = ''
    makeWrapper '${nodejs}/bin/node' "$out/bin/jellyseerr" --add-flags \
        "$out/libexec/jellyseerr/deps/jellyseerr/dist/index.js" \
        --set NODE_ENV production
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Fork of overseerr for jellyfin support";
    homepage = "https://github.com/Fallenbagel/jellyseerr";
    longDescription = ''
      Jellyseerr is a free and open source software application for managing
      requests for your media library. It is a a fork of Overseerr built to
      bring support for Jellyfin & Emby media servers!
    '';
    license = licenses.mit;
    maintainers = with maintainers; [ camillemndn ];
  };
}
