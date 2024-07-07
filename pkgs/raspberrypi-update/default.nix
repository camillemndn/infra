{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  curl,
  gawk,
  raspberrypi-eeprom,
  raspberrypi-utils,
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

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    install rpi-update $out/bin
    wrapProgram $out/bin/rpi-update \
      --prefix PATH : ${
        lib.makeBinPath [
          curl
          gawk
          raspberrypi-eeprom
          raspberrypi-utils
        ]
      }
  '';

  meta = with lib; {
    description = "An easier way to update the firmware of your Raspberry Pi";
    homepage = "https://github.com/raspberrypi/rpi-update";
    license = licenses.mit;
    maintainers = with maintainers; [ camillemndn ];
    mainProgram = "rpi-update";
    platforms = platforms.all;
  };
}
