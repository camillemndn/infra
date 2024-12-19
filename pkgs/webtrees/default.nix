{
  lib,
  php84,
  fetchNpmDeps,
  nodejs,
  npmHooks,
  fetchFromGitHub,
  nix-update-script,
}:

php84.buildComposerProject rec {
  pname = "webtrees";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "fisharebest";
    repo = "webtrees";
    rev = version;
    hash = "sha256-Q225wwXqW76SFoobM7eGITA6/kOpIag6EgA8e8S+tkU=";
    fetchSubmodules = true;
  };

  npmDeps = fetchNpmDeps {
    name = "${pname}-npm-deps-${version}";
    inherit src;
    hash = "sha256-V5kXyKw7amKKmz9YQngDgFcPraQUrSGBT1UsHEAJbww=";
  };

  vendorHash = "sha256-fv/6RlwjF5W4m7539pOUrRQPtJmHEwmdi/PrO+vGdII=";

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  postBuild = ''
    rm -r public/css/{*.css,colors} public/js
    npm run production
  '';

  composerStrictValidation = false;

  postInstall = ''
    php index.php compile-po-files
    for FILE in resources/lang/*/messages.php; do cp $FILE $out/share/php/webtrees/$FILE; done
    find $out -name "*.po" -delete
    rm -r $out/share/php/webtrees/{node_modules,tests,*.dist,*.js,*.json,*.lock,*.neon,.*}
    rm -r $out/share/php/webtrees/resources/{css,js}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Online genealogy";
    homepage = "https://webtrees.net/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ camillemndn ];
    platforms = lib.platforms.all;
  };
}
