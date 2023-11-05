{ buildNpmPackage
, fetchFromGitHub
}:

buildNpmPackage rec {
  pname = "zotero-translators";
  version = builtins.substring 0 9 src.rev;

  src = fetchFromGitHub {
    owner = "zotero";
    repo = "translators";
    rev = "ab8a83ebba9a165ad44ace10b24c582c1bd52424";
    hash = "sha256-dr2bhjcoahAZiR0TerC8KFgihTFXr4l0VILls4iSaFA=";
  };

  npmDepsHash = "sha256-pOAwpHbcCVUq7iTlahZEttbGdieSoTL28R6a6h4gjWg=";
  npmFlags = [ "--legacy-peer-deps" ];
  NODE_OPTIONS = "--openssl-legacy-provider";

  postPatch = ''
    # Remove unused dependency
    sed -i package.json -e '/eslint-plugin-zotero-translator/d'

    # Avoid downloading binary in sandbox
    echo "chromedriver_skip_download=true" >> .npmrc
  '';

  dontNpmBuild = true;
}
