{ lib
, stdenv
, fetchFromGitHub
, fetchYarnDeps
, yarn
, fixup_yarn_lock
, nodejs-16_x
}:

stdenv.mkDerivation rec {
  pname = "signal-desktop";
  version = "6.10.1";

  src = fetchFromGitHub {
    owner = "signalapp";
    repo = "Signal-Desktop";
    rev = "v${version}";
    hash = "sha256-xFie5fAvaVUgddVwA/IC8/TCYRT/rFvjaFhJcBPvWrs=";
  };

  postPatch = ''
    # Add the custom yarn.lock
    rm yarn.lock 
    cp ${./yarn.lock} yarn.lock
    chmod +rw yarn.lock
  '';

  offlineCache = fetchYarnDeps {
    yarnLock = ./yarn.lock;
    sha256 = "sha256-CZBd2pTO5VLulMxBbGQ8pOpHizM4pZBtpLztpr3Phyw=";
  };

  buildInputs = [ yarn fixup_yarn_lock nodejs-16_x ];

  buildPhase = ''
    runHook preBuild
    export HOME=$PWD
    export NODE_OPTIONS=--openssl-legacy-provider
    fixup_yarn_lock yarn.lock
    yarn config --offline set yarn-offline-mirror $offlineCache
    yarn --offline --frozen-lockfile --ignore-scripts --ignore-engines  
    yarn generate
    yarn build:webpack
  '';

  meta = with lib; {
    description = "A private messenger for Windows, macOS, and Linux";
    homepage = "https://github.com/signalapp/Signal-Desktop";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.all;
  };
}
