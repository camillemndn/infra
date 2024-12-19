{
  lib,
  php83,
  fetchFromGitHub,
  nix-update-script,
}:

php83.buildComposerProject rec {
  pname = "koel";
  version = "7.2.0";

  src = fetchFromGitHub {
    owner = "koel";
    repo = "koel";
    rev = "v${version}";
    hash = "sha256-XnDbHI2eJk8gJWLN6GE+ApSILEMFSUkGElEjmPNpYlQ=";
    fetchSubmodules = true;
  };

  php = php83.buildEnv { extensions = { enabled, all }: enabled ++ (with all; [ xsl ]); };

  vendorHash = "sha256-e9YxZeToiHJcT9BankKjvYMTJ1Fc1vvgFofBYHs5DAw=";
  composerStrictValidation = false;

  postInstall = ''
    rm $out/share/php/koel/composer.lock
    touch $out/share/php/koel/.env
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A personal music streaming server that works";
    homepage = "https://github.com/koel/koel";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ camillemndn ];
    platforms = lib.platforms.all;
  };
}
