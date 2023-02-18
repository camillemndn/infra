{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, nodejs
, nodePackages
, sqlite
, fetchYarnDeps
, python3
, jq
, yarn2nix-moretea
}:

let
  workspace = yarn2nix-moretea.mkYarnWorkspace {
    src = fetchFromGitHub {
      owner = "overleaf";
      repo = "overleaf";
      rev = "4f89588fb4195b1314155557d0497563acf4a1b4";
      sha256 = "sha256-Le+BaxKBKm4zYb9GIOxWkl8AezptqgRmJiu/2/tK0AI=";
    };
    version = "unstable";

    yarnLock = ./yarn.lock;
  };
in

workspace.overleaf-chat.overrideAttrs (final: prev: {
  pname = "overleaf";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "overleaf";
    repo = "overleaf";
    rev = "4f89588fb4195b1314155557d0497563acf4a1b4";
    sha256 = "sha256-Le+BaxKBKm4zYb9GIOxWkl8AezptqgRmJiu/2/tK0AI=";
  };

  yarnLock = ./yarn.lock;

  yarnFlags = [ "--ignore-engines" ];

  offlineCache = fetchYarnDeps {
    yarnLock = ./yarn.lock;
    sha256 = "sha256-FqxVv7xH3wMZYvaOmYJW4K0rPQxoTy71D1X9NjvkABc=";
  };

  postPatch = ''
        for i in $(find . -name "package.json")
        do
    	if [ -z $(jq '.version // empty' "$i") ]
    	then
    		cat <<< "$(jq '. + { version: "0.0.0" }' "$i")" > "$i"
    	fi
        done
        #rm package-lock.json
        cp ${./yarn.lock} yarn.lock
  '';

  nativeBuildInputs = [
    jq
    nodejs
    makeWrapper
  ];

  # Fixes "SQLite package has not been found installed" at launch
  #pkgConfig.sqlite3.postInstall = ''
  #  export CPPFLAGS="-I${nodejs}/include/node"
  #  ${nodePackages.node-pre-gyp}/bin/node-pre-gyp install --prefer-offline --build-from-source --python=${python3}/bin/python --nodedir=${nodejs}/include/node
  #'';

  buildPhase = ''
    runHook preBuild
    (
      cd deps/@overleaf/chat
      #mkdir test
      #echo ${(lib.concatStrings (lib.mapAttrsToList (name: value: name) workspace.overleaf-web))} 
      ls -all
      #ls -all node_modules/.bin 
      #./node_modules/.bin/webpack --config webpack.config.prod.js
      yarn workspace "@overleaf/chat" run
    )  
    runHook postBuild
  '';

  doDist = false;

  installPhase = ''
    mkdir $out
  '';

  postInstall = ''
    #makeWrapper '${nodejs}/bin/node' "$out/bin/overleaf" --add-flags \
       # "$out/libexec/overleaf/deps/overleaf/dist/index.js" \
        #--set NODE_ENV production
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Fork of overseerr for jellyfin support";
    homepage = "https://github.com/Fallenbagel/overleaf";
    longDescription = ''
      Overleaf is a free and open source software application for managing
      requests for your media library. It is a a fork of Overseerr built to
      bring support for Jellyfin & Emby media servers!
    '';
    license = licenses.mit;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.linux;
  };
})
