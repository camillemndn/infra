{ lib, stdenv, fetchurl, glibc, gcc-unwrapped, autoPatchelfHook, ... }:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  availablePlats = {
    x86_64-linux = "linux_amd64";
    # x86_64-darwin = "darwin_amd64";
    aarch64-linux = "linux_arm64";
    # aarch64-darwin = "darwin_arm64";
    armv7l-linux = "linux_armv7";
    armv6l-linux = "linux_armv6";
  };

  plat = availablePlats.${system} or throwSystem;

  archive_fmt = if stdenv.isDarwin then "zip" else "tar.gz";

  sha256 = {
    x86_64-linux = "sha256-dxazml2t7nqWPnWUOhN2k5YoxzqZ8LzhLTs19sTmbdU=";
    x86_64-darwin = "0l5s7ba3gd7c73dag52ccd26076a37jvr5a3npyd0078nby0d5n4";
    aarch64-linux = "073czaap96dbchmsdx7cjqfm68pgimwrngmy2rfgj4b7a0iw3jg6";
    aarch64-darwin = "1nlsxpjw4cx0z0g7jx5z3v9j6l4vka5w1ijsf2qvrwa27pp8n6hk";
    armv7l-linux = "10vcmizrk19qa8l01hkvxlay8gqk5qlkx0kpax0blkk91cifqzg7";
    armv6l-linux = "10vcmizrk19hi8l01hkvxlay8gqk5qlcx0kpax0blkk91cifqzg7";
  }.${system} or throwSystem;
in

stdenv.mkDerivation rec {
  pname = "sheetable";
  version = "0.8.1";

  src = fetchurl {
    url = "https://github.com/SheetAble/SheetAble/releases/download/v${version}/SheetAble_${version}_${plat}.tar.gz";
    inherit sha256;
  };

  setSourceRoot = "sourceRoot=`pwd`";

  installPhase = ''
    mkdir -p $out/bin
    mv * $out/bin/.
  '';

  # Required for compilation
  nativeBuildInputs = [
    autoPatchelfHook # Automatically setup the loader, and do the magic
  ];

  # Required at running time
  buildInputs = [
    glibc
    gcc-unwrapped
  ];

  meta = with lib; {
    description = "Self-hosted music sheet organizing software";
    homepage = "https://sheetable.net/";
    license = licenses.gpl3Only;
    # maintainers = with maintainers; [ camillemndn ];
    platforms = mapAttrsToList (name: value: (toString name)) availablePlats;
  };
}
