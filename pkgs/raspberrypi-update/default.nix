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
  pname = "raspberrypi-update";
  version = "0-unstable-2024-09-10";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "rpi-update";
    rev = "7ce981c2125b2dd780f4e88dc320e1570dc4c51e";
    hash = "sha256-sNtxC/+T2LCgcmR9+PCau6bTmv1B2uyktyZuYaiBNdk=";
  };

  postPatch = ''
    sed -i rpi-update -e "/ldconfig -r/d"
  '';

  nativeBuildInputs = [ makeWrapper ];

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

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "An easier way to update the firmware of your Raspberry Pi";
    homepage = "https://github.com/raspberrypi/rpi-update";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ camillemndn ];
    mainProgram = "rpi-update";
    platforms = lib.platforms.all;
  };
}
