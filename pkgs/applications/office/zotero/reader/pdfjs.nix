{ buildNpmPackage
, fetchFromGitHub
}:

buildNpmPackage rec {
  pname = "zotero-reader-pdfjs";
  version = builtins.substring 0 9 src.rev;

  src = fetchFromGitHub {
    owner = "zotero";
    repo = "pdf.js";
    rev = "3f71a8aed2b72207688cd0e2c010a6d37f446220";
    hash = "sha256-n4Y0J7Xh6Wi2KIBnxYWPOaBqueyOTiA1ZW9sC2uollI=";
  };

  npmDepsHash = "sha256-9e90iIKwWyBq68q/CKn+7laJwPFtJaZtblcWpIEDSXw=";
  npmFlags = [ "--legacy-peer-deps" ];
  NODE_OPTIONS = "--openssl-legacy-provider";
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
}
