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
  version = "2024-05-07";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "rpi-update";
    rev = "f6fa0ed03ed1a36aae889bf0651ace310fbdf662";
    hash = "sha256-l0KobTkLCKB/VfPW4kVDc2VSTcO96cXDERri77cJ9eM=";
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
