{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "webtrees";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "fisharebest";
    repo = "webtrees";
    rev = version;
    hash = "sha256-060n/j7yMXipTb1XBaHn/3UO8gz/bIzUJGBq7RG5A8I=";
  };

  installPhase = ''
    mkdir -p $out/share
    mv * $out/share
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
