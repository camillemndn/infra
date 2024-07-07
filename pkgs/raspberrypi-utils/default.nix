{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  dtc,
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

  meta = with lib; {
    description = "A collection of scripts and simple applications";
    homepage = "https://github.com/raspberrypi/utils";
    license = licenses.bsd3;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.all;
  };
}
