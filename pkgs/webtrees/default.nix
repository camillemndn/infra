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
  version = "2.2.6";

  src = fetchFromGitHub {
    owner = "fisharebest";
    repo = "webtrees";
    rev = version;
    hash = "sha256-1AWn2c1RDSek2c5nZ6/obJjDx5eENGdRw3q2IyV1qkg=";
    fetchSubmodules = true;
  };

  npmDeps = fetchNpmDeps {
    name = "${pname}-npm-deps-${version}";
    inherit src;
    hash = "sha256-l9OguC59KFZFbDCMhJFocuepLMurC3b/DPvEqZhFNhs=";
  };

  vendorHash = "sha256-/StT0p/uieWjtiS8TxucDeS8fkNUs2zCDj+tlL/AkN0=";

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  postBuild = ''
    rm -r public/css/*.css public/js
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
