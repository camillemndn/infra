{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  binutils,
  coreutils,
  curl,
  gawk,
  gnugrep,
  gnutar,
  gzip,
  libuuid,
  raspberrypi-eeprom,
  raspberrypi-utils,
  nix-update-script,
}:

stdenv.mkDerivation {
  installPhase = ''
    mkdir -p $out/bin
    install rpi-update $out/bin
    wrapProgram $out/bin/rpi-update \
      --set UPDATE_SELF 0 \
      --set PATH ${
        lib.makeBinPath [
          binutils
          coreutils
          curl
          gawk
          gnugrep
          gnutar
          gzip
          libuuid
          raspberrypi-eeprom
          raspberrypi-utils
        ]
      }
  '';

  meta = {
    description = "An easier way to update the firmware of your Raspberry Pi";
    homepage = "https://github.com/raspberrypi/rpi-update";
    license = lib.licenses.mit;
    mainProgram = "rpi-update";
    maintainers = with lib.maintainers; [ camillemndn ];
    platforms = lib.platforms.all;
  };

  nativeBuildInputs = [ makeWrapper ];
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  pname = "raspberrypi-update";

  postPatch = ''
    sed -i rpi-update -e "/ldconfig -r/d"
  '';

  src = fetchFromGitHub {
    hash = "sha256-W60Yvg5ibXkptHQ7Hmy1IKCd/Qkv0R5f6I4CJtRIEx8=";
    owner = "raspberrypi";
    repo = "rpi-update";
    rev = "0fd4cffe552e9c323ca97d89ccdc25f63e112f8b";
  };

  version = "0-unstable-2026-08-26";
}
