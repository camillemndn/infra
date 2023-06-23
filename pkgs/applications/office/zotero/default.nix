{ lib
, buildNpmPackage
, fetchFromGitHub
, firefox-esr
, makeDesktopItem
, copyDesktopItems
, python3
, unzip
, zip
, perl
, rsync
}:

let
  pname = "zotero";
  version = "7.0.0.SOURCE.3454c321e";
  rev = "3454c321e77d79db3ea337d6d0241ba5703fce79";

  meta = with lib; {
    description = "Zotero is a free, easy-to-use tool to help you collect, organize, cite, and share your research sources";
    homepage = "https://github.com/zotero/zotero";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ camillemndn ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };

  npmFlags = [ "--legacy-peer-deps" ];
  NODE_OPTIONS = "--openssl-legacy-provider";

  single-file = buildNpmPackage {
    pname = "${pname}-single-file";
    inherit version npmFlags NODE_OPTIONS meta;

    src = fetchFromGitHub {
      owner = "gildas-lormeau";
      repo = "SingleFile";
      rev = "0bca0227851348ef9bbaec780e88deb32b1cc03d";
      hash = "sha256-iP1eVkBOkdowdZlG2i/exJrSWEzyD3/HGf2maQNN7Oc=";
    };

    npmDepsHash = "sha256-wsoXotl8FLkWZYcKGUCCGc1iZn5dlmlHBdLZh0H4Zuc=";
    dontNpmBuild = true;
  };

  xpcom-utilities = buildNpmPackage {
    pname = "${pname}-xpcom-utilities";
    inherit version npmFlags NODE_OPTIONS meta;

    src = fetchFromGitHub {
      owner = "zotero";
      repo = "utilities";
      rev = "cccf1235a318c259345fc623d5e9d6770ba19df7";
      hash = "sha256-YnjB8xYfLHrJpmCrGSgwR/UTHg0X40H6JG/WNqo8xUc=";
    };

    npmDepsHash = "sha256-tWDADhAeXG0HSvFnpdGOya3CjSb0i2aR3E1Y3r1J81o=";
    dontNpmBuild = true;
  };

  note-editor = buildNpmPackage {
    pname = "${pname}-note-editor";
    inherit version npmFlags NODE_OPTIONS meta;

    src = fetchFromGitHub {
      owner = "zotero";
      repo = "note-editor";
      rev = "076f5b3d3609051b9cba3cd68c4bb22746187834";
      hash = "sha256-ZDmb3DQttftfS4w5+HlkTXRxhRYftBh1bm6MI+RBvII=";
    };

    npmDepsHash = "sha256-yu2s4V2hB07eS0INVxQXU7YeWYmR3p4JPxKWuCK3Iys=";

    postInstall = ''
      cp -r build $out/lib/node_modules/zotero-note-editor/build
    '';
  };

  translators = buildNpmPackage {
    pname = "${pname}-translators";
    inherit version npmFlags NODE_OPTIONS meta;

    src = fetchFromGitHub {
      owner = "zotero";
      repo = "translators";
      rev = "ab8a83ebba9a165ad44ace10b24c582c1bd52424";
      hash = "sha256-dr2bhjcoahAZiR0TerC8KFgihTFXr4l0VILls4iSaFA=";
    };

    npmDepsHash = "sha256-pOAwpHbcCVUq7iTlahZEttbGdieSoTL28R6a6h4gjWg=";

    postPatch = ''
      # Remove unused dependency
      sed -i package.json -e '/eslint-plugin-zotero-translator/d'

      # Avoid downloading binary in sandbox
      echo "chromedriver_skip_download=true" >> .npmrc
    '';

    dontNpmBuild = true;
  };

  pdf-reader-pdfjs = buildNpmPackage {
    pname = "${pname}-pdf-reader-pdfjs";
    inherit version npmFlags NODE_OPTIONS meta;

    src = fetchFromGitHub {
      owner = "zotero";
      repo = "pdf.js";
      rev = "3f71a8aed2b72207688cd0e2c010a6d37f446220";
      hash = "sha256-n4Y0J7Xh6Wi2KIBnxYWPOaBqueyOTiA1ZW9sC2uollI=";
    };

    npmDepsHash = "sha256-9e90iIKwWyBq68q/CKn+7laJwPFtJaZtblcWpIEDSXw=";
    makeCacheWritable = true;

    postPatch = ''
      # Add a version number
      sed -i package*.json -e '/"name": "pdf.js"/a "version": "1.0.0",'
    '';

    buildPhase = ''
      node_modules/.bin/gulp generic
    '';

    postInstall = ''
      cp -r build $out/lib/node_modules/pdf.js/build
    '';
  };

  pdf-worker-pdfjs = buildNpmPackage {
    pname = "${pname}-pdf-worker-pdfjs";
    inherit version npmFlags NODE_OPTIONS meta;

    src = fetchFromGitHub {
      owner = "zotero";
      repo = "pdf.js";
      rev = "e198a17afc6f56e0a9d48b07e42ec80645a7a0a8";
      hash = "sha256-FlKII11oPMPka+96Wo9ZjBuNp40i3OMuvlNz8X/r0Lw=";
    };

    npmDepsHash = "sha256-9e90iIKwWyBq68q/CKn+7laJwPFtJaZtblcWpIEDSXw=";
    makeCacheWritable = true;

    postPatch = ''
      # Add a version number
      sed -i package*.json -e '/"name": "pdf.js"/a "version": "1.0.0",'
    '';

    buildPhase = ''
      node_modules/.bin/gulp lib
    '';

    postInstall = ''
      cp -r build $out/lib/node_modules/pdf.js/build
    '';
  };

  pdf-reader = buildNpmPackage {
    pname = "${pname}-pdf-reader";
    src = fetchFromGitHub {
      owner = "zotero";
      repo = "pdf-reader";
      rev = "c963b7e3f9bb8aa4bfeb39dfc0fbce3a4a33985e";
      hash = "sha256-qhsoS9rW01EWsoMo3HUyU5U+Mkui8eC+bWdsNcKjGV0=";
    };
    inherit version npmFlags NODE_OPTIONS meta;
    npmDepsHash = "sha256-tDr2WLnpltWPrlF21M8G/We4zzAXBp4px5xceOVLbhQ=";

    postPatch = ''
      # Avoid npm install since it is handled by buildNpmPackage
      sed -i scripts/build-pdfjs \
        -e 's/npx gulp/#npx gulp/g' \
        -e 's/npm ci/#npm ci/g'
    '';

    buildPhase = ''
      rm -rf pdf.js
      cp -Lr ${pdf-reader-pdfjs}/lib/node_modules/pdf.js pdf.js
    '';

    preInstall = ''
      mkdir -p $out/lib/node_modules/pdf-reader
      cp -r node_modules $out/lib/node_modules/pdf-reader/node_modules
    '';
  };

  pdf-worker = buildNpmPackage {
    pname = "${pname}-pdf-worker";
    src = fetchFromGitHub {
      owner = "zotero";
      repo = "pdf-worker";
      rev = "84e7814cf72f4234d2c0126aa0d7dbad712c196b";
      hash = "sha256-xR0hOzQi76k6YSDd0Zq3BYZZ+InKNUw0t7pbtE6Rwe4=";
    };
    inherit version npmFlags NODE_OPTIONS meta;
    npmDepsHash = "sha256-rO/P7/22erxNeOpR8ph7taKyCeOEG9+U06oOfmPSa3w=";

    postPatch = ''
      # Avoid npm install since it is handled by buildNpmPackage
      sed -i scripts/build-pdfjs \
        -e 's/npx gulp/#npx gulp/g' \
        -e 's/npm ci/#npm ci/g'
    '';

    buildPhase = ''
      rm -rf pdf.js
      cp -Lr ${pdf-worker-pdfjs}/lib/node_modules/pdf.js pdf.js
    '';

    preInstall = ''
      mkdir -p $out/lib/node_modules/pdf-worker
      cp -r node_modules $out/lib/node_modules/pdf-worker/node_modules
    '';
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = "${pname} -url %U";
    icon = "zotero";
    comment = meta.description;
    desktopName = "Zotero";
    genericName = "Reference Management";
    categories = [ "Office" "Database" ];
    startupNotify = true;
    startupWMClass = pname;
    mimeTypes = [ "x-scheme-handler/zotero" "text/plain" ];
    terminal = false;
    actions = {
      profile-manager-window = {
        name = "Profile Manager";
        exec = "${pname} -P";
      };
    };
  };
in

buildNpmPackage {
  inherit pname version npmFlags NODE_OPTIONS meta;

  src = fetchFromGitHub {
    owner = "zotero";
    repo = "zotero";
    inherit rev;
    hash = "sha256-ft26Oo7zbFOML/TsiRjZTsK5fO0DQqUFeYK9fGxT3pk=";
    fetchSubmodules = true;
  };

  npmDepsHash = "sha256-P0C7BICZx2oGVH1OK4IobB4fxzGSBZoV/FDQBKiasDg=";

  patches = [ ./dark-tabs.patch ];

  postPatch = ''
    # Replace Git submodules by their respective NPM packages
    
    rm -rf resource/SingleFile
    cp -Lr ${single-file}/lib/node_modules/single-file resource/SingleFile

    rm -rf chrome/content/zotero/xpcom/utilities
    cp -Lr ${xpcom-utilities}/lib/node_modules/@zotero/utilities chrome/content/zotero/xpcom/utilities

    rm -rf pdf-reader
    cp -r ${pdf-reader}/lib/node_modules/pdf-reader pdf-reader

    rm -rf pdf-worker
    cp -r ${pdf-worker}/lib/node_modules/pdf-worker pdf-worker

    chmod +w pdf-{reader,worker} -R

    (
      cd pdf-reader
      rm -rf pdf.js
      cp -Lr ${pdf-reader-pdfjs}/lib/node_modules/pdf.js pdf.js
    )
    (
      cd pdf-worker
      rm -rf pdf.js
      cp -Lr ${pdf-worker-pdfjs}/lib/node_modules/pdf.js pdf.js
    )

    rm -rf translators
    cp -Lr ${translators}/lib/node_modules/translators-check translators

    rm -rf note-editor
    cp -Lr ${note-editor}/lib/node_modules/zotero-note-editor note-editor

    chmod +w . -R

    # Avoid npm install and using git
    find js-build -type f | xargs sed -i 's/npm ci/#npm ci/g'
    find js-build -type f | xargs sed -i 's/git/#git/g'

    # Avoid npm build since it is already built
    sed -i js-build/note-editor.js -e 's/npm run build/#npm run build/g'

    # Zotero standalone build scripts
    patchShebangs app/build.sh app/scripts/{dir_build,fetch_xulrunner,prepare_build}
    
    # Fix Firefox runtime fetching 
    sed -i app/scripts/fetch_xulrunner \
      -e '/updateAuto/,+7d' \
      -e 's/curl.*/:/' \
      -e 's/firefox-x86_64/firefox/g' \
      -e '/pushd firefox-i686/,+3d' \
      -e '/linux32/d' \
      -e '/rm -rf firefox/d' \
      -e '/mv firefox/d' \
      -e '/bz2/d' \
      -e '/xulrunner_hash/d'
    
    # Use the hash from this revision
    sed -i app/scripts/dir_build -Ee 's/(.*hash=).*/\1${rev}/'

    # Make the copied files writable after rsync and remove multiple arch build
    sed -i app/build.sh \
      -Ee 's|(rsync -a.*)|\1; chmod -R +w $BUILD_DIR|' \
      -e 's/x86_64//g' \
      -e 's/firefox-"/firefox"/g' \
      -e 's/Zotero_linux-/Zotero_linux/g' \
      -e 's/for arch in \$archs/for arch in ""/g' \
      -e '/linux\/updater.tar.xz/,+3d'
  '';

  nativeBuildInputs = [ rsync python3 unzip zip perl rsync ];
  buildInputs = [ copyDesktopItems ];
  desktopItems = [ desktopItem ];

  postBuild = ''
    mkdir app/xulrunner
    cp -Lr ${firefox-esr}/lib/firefox app/xulrunner
    chmod -R +w /build
    app/scripts/dir_build -p l
    
    patchShebangs app/staging/Zotero_linux/zotero
    sed -i app/staging/Zotero_linux/zotero -e '/MOZ_LEGACY_PROFILES/a export MOZ_ENABLE_WAYLAND=1'
  '';

  installPhase = ''
    mkdir -p $out/{bin,lib}
    cp -Lr app/staging/Zotero_linux $out/lib/zotero
    ln -s $out/lib/zotero/zotero $out/bin

    for size in 16 32 48 256; do
      install -Dm444 app/staging/Zotero_linux/chrome/icons/default/default$size.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/zotero.png
    done
  '';
}
