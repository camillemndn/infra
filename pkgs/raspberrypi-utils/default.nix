{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  dtc,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "raspberrypi-utils";
  version = "2024-05-23";

  src = fetchFromGitHub {
    owner = "raspberrypi";
    repo = "utils";
    rev = "b9c63214c535d7df2b0fa6743b7b3e508363c25a";
    hash = "sha256-+z3nSILfI0YZHWKy90SV2Z2fziaAGEC4AKamEpf2+pQ=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ dtc ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "A collection of scripts and simple applications";
    homepage = "https://github.com/raspberrypi/utils";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ camillemndn ];
    platforms = lib.platforms.all;
  };
}
