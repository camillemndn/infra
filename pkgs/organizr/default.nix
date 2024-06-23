{
  stdenv,
  lib,
  fetchzip,
  ...
}:

let
  commit = "fa58690db99f6b19174278085b369b926ada42be";
in

stdenv.mkDerivation rec {
  pname = "organizr";
  version = "2.1.2380-dev";

  src = fetchzip {
    url = "https://github.com/causefx/Organizr/archive/${commit}.zip";
    sha256 = "sha256-KvLFZZeBMGhDgp8s+bemsgIovTLF3JmG/IJzPbRL5uI=";
  };

  patches = [ ./remove_write_check.diff ];

  installPhase = ''
    mkdir -p $out/data
    mv * $out
  '';

  meta = with lib; {
    description = "Organizr is a php based web front-end to help organize your services";
    homepage = "https://organizr.app/";
    license = licenses.mit;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.linux;
  };
}
