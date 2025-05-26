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
  version = "0-unstable-2025-04-15";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "rpi-update";
    rev = "5114bb59da5db8c3725966e8f7a2f7b8a158b15a";
    hash = "sha256-DxmMUgMLoFVIvZ+1fE0H8wDLd0Y1Q5mc0lxg0uzjUrM=";
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
