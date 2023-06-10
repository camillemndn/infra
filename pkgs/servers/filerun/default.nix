{ lib, stdenv, fetchurl, fetchzip, unzip, ... }:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  availablePlats = {
    x86_64-linux = "lin_x86-64";
    x86_64-darwin = "mac_x86-64";
    aarch64-linux = "lin_aarch64";
    aarch64-darwin = "dar_arm64";
    armv7l-linux = "lin_armv7l";
  };

  plat = availablePlats.${system} or throwSystem;

  sha256 = {
    x86_64-linux = "sha256-gP+urlOzNSf7woaFNXlG6TjB0eXrEJaT/uRZjDjWcCk=";
    x86_64-darwin = "0l5s7ba3gd7f73dag52ccd26076a37jvr5a3npyd0078nby0d5n4";
    aarch64-linux = "073czaap96ddchmsdx7cjqfm68pgimwrngmy2rfgj4b7a0iw3jg6";
    aarch64-darwin = "1nlsxpjw4ci0z0g7jx5z3v9j6l4vka5w1ijsf2qvrwa27pp8n6hk";
    armv7l-linux = "10vcmizrk19qi8l01hkvxlay8gqk5qlkx0kpax0blkk91cifqzg7";
  }.${system} or throwSystem;
in

stdenv.mkDerivation rec {
  pname = "filerun";
  version = "20220519";

  src = fetchurl {
    url = "https://www.filerun.com/download-latest";
    sha256 = "sha256-AgxZTQ11yWo3hGr/Bxg9IxMUqyqOJMIex4ug+FiM/jY=";
  };
  src_ioncube = fetchzip {
    url = "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_${plat}.tar.gz";
    inherit sha256;
  };

  patches = [ ./french.patch ];

  dontUnpack = true;

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    mkdir -p $out/ioncube
    unzip $src -d $out
    cp $src_ioncube/ioncube_loader_lin_7.4.so $out/ioncube/
  '';

  meta = with lib; {
    description = "Probably the best File Manager in the world with desktop Sync and File Sharing";
    homepage = "https://filerun.com/";
    license = licenses.unfree;
    maintainers = with maintainers; [ camillemndn ];
    platforms = mapAttrsToList (name: _: (toString name)) availablePlats;
  };
}
