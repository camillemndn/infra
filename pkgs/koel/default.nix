{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "koel";
  version = "7.2.0";

  src = fetchFromGitHub {
    owner = "koel";
    repo = "koel";
    rev = "v${version}";
    hash = "sha256-XnDbHI2eJk8gJWLN6GE+ApSILEMFSUkGElEjmPNpYlQ=";
  };

  installPhase = ''
    mkdir -p $out/share
    shopt -s dotglob
    mv * $out/share
    touch $out/share/.env
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
