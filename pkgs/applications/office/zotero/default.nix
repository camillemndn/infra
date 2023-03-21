{ lib
, stdenv
, buildNpmPackage
, buildMozillaMach
, fetchgit
, fetchFromGitHub
, fetchzip
, fetchurl
, firefox-esr-102-unwrapped
, chromedriver
, git
, callPackage
, python3
, pkg-config
, pixman
, freetype
, glib
, harfbuzz
, cairo
, pango
, libpng
, libjpeg
, giflib
, librsvg
, unzip
, zip
, perl
, rsync
}:

let
  pname = "zotero";
  version = "7.0.0";
  hash = "tocomplete";

  src = fetchFromGitHub {
    owner = "zotero";
    repo = "zotero";
    rev = "b1595cdd1d7edcf8382cc26fef92a86606df94da";
    hash = "sha256-+Ilg94S1Qk3JFEl+cAtUONiwDWC1NPYPQbF+HjKq31c=";
    fetchSubmodules = true;
    leaveDotGit = true;
  };

  zotero-build = stdenv.mkDerivation {
    pname = "${pname}-build";
    inherit version meta;
    src = fetchFromGitHub {
      owner = "zotero";
      repo = "zotero-build";
      rev = "00e854c6588f329b714250e450f4f7f663aa0222";
      hash = "sha256-Gvt37jObgSQ10GBYjnCLu5XbUAy3oVTkWPvHbhLF+fw=";
      fetchSubmodules = true;
    };

    postPatch = ''
      sed -i -E "/-aL/a '--chmod=Du=rwx'," xpi/build_xpi
      #sed -i 's/-aL/-L/' xpi/build_xpi
    '';

    buildInputs = [ python3 rsync perl ];

    buildPhase = ''
      python3 xpi/build_xpi -s ${zotero-client}/build -c source -m ${hash}
    '';

    installPhase = ''
      mkdir $out
      cp -r . $out
    '';
  };

  pdftools-version = "0.0.5";
  pdftools = fetchzip {
    url = "https://zotero-download.s3.amazonaws.com/pdftools/pdftools-${pdftools-version}.tar.gz";
    hash = "sha256-cvd0cJcuhSd2BTgRc5mz0bP9DakEKG/LK2onKOhes04=";
    stripRoot = false;
  };

  firefox = firefox-esr-102-unwrapped;

  #firefox = fetchzip {
  #  url = "https://ftp.mozilla.org/pub/firefox/releases/60.9.0esr/linux-x86_64/en-US/firefox-60.9.0esr.tar.bz2";
  #  hash = "sha256-sjbxetoLveCCNniUH4epGQzKBeQ1MJnGBwYSPbUDkoo=";
  #};

  #ffversion = "60.8.0esr";
  #firefox = buildMozillaMach {
  #  pname = "firefox-esr-60";
  #  version = "60.8.0esr";
  #  applicationName = "Mozilla Firefox ESR";
  #  src = fetchurl {
  #    url = "mirror://mozilla/firefox/releases/${ffversion}/source/firefox-${ffversion}.source.tar.xz";
  #    sha512 = "0332b6049b97e488e55a3b9540baad3bd159e297084e9a625b8492497c73f86eb3e144219dabc5e9f2c2e4a27630d83d243c919cd4f86b7f59f47133ed3afc54";
  #  };

  #meta = {
  #  changelog = "https://www.mozilla.org/en-US/firefox/${lib.removeSuffix "esr" version}/releasenotes/";
  #  description = "A web browser built from Firefox Extended Support Release source tree";
  #  homepage = "http://www.mozilla.com/en-US/firefox/";
  #  maintainers = with lib.maintainers; [ hexa ];
  #  platforms = lib.platforms.unix;
  #  badPlatforms = lib.platforms.darwin;
  #  broken = stdenv.buildPlatform.is32bit; # since Firefox 60, build on 32-bit platforms fails with "out of memory".
  #  # not in `badPlatforms` because cross-compilation on 64-bit machine might work.
  #  license = lib.licenses.mpl20;
  #};
  #};

  npmSubmodules = {
    single-file = buildNpmPackage {
      pname = "${pname}-single-file";
      inherit src version npmFlags NODE_OPTIONS meta;
      sourceRoot = "source/resource/SingleFile";
      npmDepsHash = "sha256-L4LuD7n8c42TPpbLWuJzeM27xcsXVdBnMTqNvRZMdz8=";
      dontNpmBuild = true;
    };

    xpcom-utilities = buildNpmPackage {
      pname = "${pname}-xpcom-utilities";
      inherit src version npmFlags NODE_OPTIONS meta;
      sourceRoot = "source/chrome/content/zotero/xpcom/utilities";
      npmDepsHash = "sha256-tWDADhAeXG0HSvFnpdGOya3CjSb0i2aR3E1Y3r1J81o=";
      dontNpmBuild = true;
    };

    note-editor = buildNpmPackage {
      pname = "${pname}-note-editor";
      inherit src version npmFlags NODE_OPTIONS meta;
      sourceRoot = "source/note-editor";
      npmDepsHash = "sha256-yu2s4V2hB07eS0INVxQXU7YeWYmR3p4JPxKWuCK3Iys=";
      postInstall = ''
        cp -r build $out/lib/node_modules/zotero-note-editor/build
      '';
    };

    translators = buildNpmPackage {
      pname = "${pname}-translators";
      inherit src version npmFlags NODE_OPTIONS meta;
      sourceRoot = "source/translators";
      npmDepsHash = "sha256-zAf19V7X1ujzWcdCe0xIYFCpmHy3Sj7rDa3bEhEXF34=";
      CHROMEDRIVER_FILEPATH = "${chromedriver}/bin/chromedriver";
      postPatch = ''
        rm package-lock.json
        cp ${./translator-lock.json} package-lock.json
        sed -i '/eslint-plugin-zotero-translator/d' package.json
      '';
      dontNpmBuild = true;
    };

    pdf-reader-pdfjs = buildNpmPackage {
      pname = "${pname}-pdf-reader-pdfjs";
      inherit src version npmFlags NODE_OPTIONS meta;
      sourceRoot = "source/pdf-reader/pdf.js";
      npmDepsHash = "sha256-SiFBK/sUuqUki+WgzQ8Z0Mzzr2kj0eJN0L1tf6TVuh8=";

      postPatch = ''
        rm package-lock.json
        cp ${./pdf-reader-pdfjs-lock.json} package-lock.json
      '';
      dontNpmBuild = true;
      buildPhase = ''
        node_modules/.bin/gulp generic-legacy
      '';
      postInstall = ''
        cp -r build $out/lib/node_modules/pdf.js/build
      '';
    };

    pdf-reader = buildNpmPackage {
      pname = "${pname}-pdf-reader";
      inherit src version npmFlags NODE_OPTIONS meta;
      sourceRoot = "source/pdf-reader";
      npmDepsHash = "sha256-tDr2WLnpltWPrlF21M8G/We4zzAXBp4px5xceOVLbhQ=";

      postPatch = ''
        sed -i 's/npx gulp/#npx gulp/g' scripts/build-pdfjs
        sed -i 's/npm ci/#npm ci/g' scripts/build-pdfjs
      '';

      preBuild = ''
        rm -rf pdf.js 
        cp -Lr ${npmSubmodules.pdf-reader-pdfjs}/lib/node_modules/pdf.js pdf.js
        #chmod +x pdf.js -R  
      '';
      dontNpmBuild = true;
      preInstall = ''
        mkdir -p $out/lib/node_modules/pdf-reader
        cp -r node_modules $out/lib/node_modules/pdf-reader/node_modules
      '';
    };

    pdf-worker-pdfjs = buildNpmPackage {
      pname = "${pname}-pdf-worker-pdfjs";
      inherit src version npmFlags NODE_OPTIONS meta;
      sourceRoot = "source/pdf-reader/pdf.js";
      npmDepsHash = "sha256-SiFBK/sUuqUki+WgzQ8Z0Mzzr2kj0eJN0L1tf6TVuh8=";
      #PUPPETEER_SKIP_DOWNLOAD = 1;
      #PKG_CONFIG_PATH = lib.makeSearchPathOutput "dev" "lib/pkgconfig" [ glib freetype pixman harfbuzz cairo pango libpng libjpeg giflib librsvg ];
      #nativeBuildInputs = [ python3 pkg-config ];
      postPatch = ''
        rm package-lock.json
        cp ${./pdf-reader-pdfjs-lock.json} package-lock.json
      '';
      dontNpmBuild = true;
      buildPhase = ''
        node_modules/.bin/gulp lib 
      '';
      postInstall = ''
        cp -r build $out/lib/node_modules/pdf.js/build
      '';
    };

    pdf-worker = buildNpmPackage {
      pname = "${pname}-pdf-worker";
      inherit src version npmFlags NODE_OPTIONS meta;
      sourceRoot = "source/pdf-worker";
      npmDepsHash = "sha256-rO/P7/22erxNeOpR8ph7taKyCeOEG9+U06oOfmPSa3w=";

      postPatch = ''
        sed -i 's/npx gulp/#npx gulp/g' scripts/build-pdfjs
        sed -i 's/npm ci/#npm ci/g' scripts/build-pdfjs
      '';

      preBuild = ''
        rm -rf pdf.js 
        cp -Lr ${npmSubmodules.pdf-worker-pdfjs}/lib/node_modules/pdf.js pdf.js
        #chmod +x pdf.js -R  
      '';
      dontNpmBuild = true;
      preInstall = ''
        mkdir -p $out/lib/node_modules/pdf-worker
        cp -r node_modules $out/lib/node_modules/pdf-worker/node_modules
      '';
    };
  };

  #buildNpmSubmodules = name: path: hash: (buildNpmPackage {
  #  pname = "zotero-${name}";

  #  inherit src version;
  #  npmDepsHash = hash;
  #});

  npmFlags = [ "--legacy-peer-deps" ];

  NODE_OPTIONS = "--openssl-legacy-provider";

  nativeBuildInputs = [ git ];

  meta = with lib; {
    description = "Zotero is a free, easy-to-use tool to help you collect, organize, cite, and share your research sources";
    homepage = "https://github.com/zotero/zotero";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.all;
  };

  #mkMerge (map buildNpmPackage submodules) //

  zotero-client = buildNpmPackage {
    pname = "${pname}-client";
    inherit src version npmFlags NODE_OPTIONS meta;
    npmDepsHash = "sha256-w75fDpHQ1T39US9bDoSl8gKtF0cswkvNu/FIl/2/508=";

    nativeBuildInputs = [ git ];

    postPatch = ''
      rm -rf resource/SingleFile 
      cp -Lr ${npmSubmodules.single-file}/lib/node_modules/single-file resource/SingleFile
      rm -rf chrome/content/zotero/xpcom/utilities
      cp -Lr ${npmSubmodules.xpcom-utilities}/lib/node_modules/@zotero/utilities chrome/content/zotero/xpcom/utilities 
      rm -rf pdf-reader 
      cp -r ${npmSubmodules.pdf-reader}/lib/node_modules/pdf-reader pdf-reader
      rm -rf pdf-worker
      cp -r ${npmSubmodules.pdf-worker}/lib/node_modules/pdf-worker pdf-worker
      rm -rf translators 
      cp -Lr ${npmSubmodules.translators}/lib/node_modules/translators-check translators 
      rm -rf note-editor
      cp -Lr ${npmSubmodules.note-editor}/lib/node_modules/zotero-note-editor note-editor
      chmod +w . -R

      #for folder in scripts pdf-reader/scripts pdf-worker/scripts
      #do
      #echo "Patching $folder"
      find scripts -type f | xargs sed -i 's/npm ci/#npm ci/g'
      #done
    
      sed -i 's/npm run build/#npm run build/g' scripts/note-editor.js
    
      (
        cd pdf-worker
        rm -rf pdf.js 
        cp -Lr ${npmSubmodules.pdf-worker-pdfjs}/lib/node_modules/pdf.js pdf.js
      )
      (
        cd pdf-reader
        rm -rf pdf.js 
        cp -Lr ${npmSubmodules.pdf-reader-pdfjs}/lib/node_modules/pdf.js pdf.js
      )
      chmod +w . -R

      #sed -i 's/cp -r.*/ls -all/g' pdf-reader/scripts/build-pdfjs
    '';

    installPhase = ''
      mkdir $out
      cp -r . $out
    '';
  };
in
stdenv.mkDerivation {
  inherit pname version meta;

  src = fetchFromGitHub {
    owner = "zotero";
    repo = "zotero-standalone-build";
    rev = "e9ef6bf21d39cc66f1edefdd5b7429bbaf0c5247";
    hash = "sha256-NcnbqCN6Pti2KuVX79QLrTk2V/3sMxMrbgRzSTluOtM=";
    fetchSubmodules = true;
  };

  patches = [ ./fetchxul.patch ];

  postPatch = ''
    patchShebangs .
    
    sed -i 's|LINUX_i686_RUNTIME_PATH=.*|LINUX_i686_RUNTIME_PATH="$DIR/xulrunner/firefox"|' config.sh
    sed -i 's|LINUX_x86_64_RUNTIME_PATH=.*|LINUX_x86_64_RUNTIME_PATH="$DIR/xulrunner/firefox"|' config.sh
    sed -i 's|ZOTERO_SOURCE_DIR=.*|ZOTERO_SOURCE_DIR="${zotero-client}"|' config.sh
    sed -i 's|ZOTERO_BUILD_DIR=.*|ZOTERO_BUILD_DIR="${zotero-build}"|' config.sh
    
    sed -i -E 's|(.*hash=).*|\1${hash}|' scripts/dir_build
    sed -i '/build_xpi/d' scripts/dir_build
    
    sed -i -E 's|(rsync -a.*)|\1; chmod -R +w $BUILD_DIR|' build.sh 
    #sed -i 's|BUILD_DIR=.*|BUILD_DIR=/build|' build.sh 
    #sed -i '/trap/d' build.sh 
    sed -i 's|MaxVersion=.*|MaxVersion=111.0|' assets/application.ini 
  '';

  nativeBuildInputs = [ python3 unzip zip perl rsync ];

  configurePhase = ''
    mkdir xulrunner
    cp -Lr ${firefox}/lib/firefox xulrunner
    #cp -Lr ${firefox} xulrunner/firefox
    chmod -R +w xulrunner
    cp -Lr ${pdftools} pdftools
    chmod -R +w pdftools 
    ./fetch_xulrunner.sh -p l
  '';

  buildPhase = ''
    chmod -R +w /build
    scripts/dir_build -p l
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp -Lr staging/Zotero_linux $out/lib

    ln -s $out/lib/zotero $out/bin/zotero
  '';
}

