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
  composerStrictValidation = false;

  meta = {
    description = "Online genealogy";
    homepage = "https://webtrees.net/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ camillemndn ];
    platforms = lib.platforms.all;
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  npmDeps = fetchNpmDeps {
    inherit src;
    hash = "sha256-l9OguC59KFZFbDCMhJFocuepLMurC3b/DPvEqZhFNhs=";
    name = "${pname}-npm-deps-${version}";
  };

  passthru.updateScript = nix-update-script { };
  pname = "webtrees";

  postBuild = ''
    rm -r public/css/*.css public/js
    npm run production
  '';

  postInstall = ''
    php index.php compile-po-files
    for FILE in resources/lang/*/messages.php; do cp $FILE $out/share/php/webtrees/$FILE; done
    find $out -name "*.po" -delete
    rm -r $out/share/php/webtrees/{node_modules,tests,*.dist,*.js,*.json,*.lock,*.neon,.*}
    rm -r $out/share/php/webtrees/resources/{css,js}
  '';

  src = fetchFromGitHub {
    fetchSubmodules = true;
    hash = "sha256-1AWn2c1RDSek2c5nZ6/obJjDx5eENGdRw3q2IyV1qkg=";
    owner = "fisharebest";
    repo = "webtrees";
    rev = version;
  };

  vendorHash = "sha256-/StT0p/uieWjtiS8TxucDeS8fkNUs2zCDj+tlL/AkN0=";
  version = "2.2.6";
}
