{ lib, stdenv, fetchurl, mono, libmediainfo, sqlite, curl, makeWrapper, icu, dotnetCorePackages, openssl, nixosTests }:

let
  os = if stdenv.isDarwin then "osx" else "linux";
  arch = {
    x86_64-linux = "x64";
    aarch64-linux = "arm64";
    x86_64-darwin = "x64";
  }."${stdenv.hostPlatform.system}" or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  hash = {
    x64-linux_hash = "sha256-FCpid2K4wktRCXSIfb/xE6Ei+0gpHvSM0en67L0C5n4=";
    arm64-linux_hash = "sha256-lCBOEZUCgwoKyV4pzPVm3HC9V4R4L+uNZLfP0rqO16c=";
    x64-osx_hash = "sha256-fPtbdjrVePbzHYffALxCmjMWzWBglNxFLec3cmqemo8=";
  }."${arch}-${os}_hash";

in
stdenv.mkDerivation rec {
  pname = "readarr";
  version = "0.1.3.1584";

  src = fetchurl {
    url = "https://github.com/Readarr/Readarr/releases/download/v${version}/Readarr.develop.${version}.${os}-core-${arch}.tar.gz";
    sha256 = hash;
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,share/${pname}-${version}}
    cp -r * $out/share/${pname}-${version}/.
    makeWrapper "${dotnetCorePackages.runtime_3_1}/bin/dotnet" $out/bin/Readarr \
      --add-flags "$out/share/${pname}-${version}/Readarr.dll" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        curl sqlite libmediainfo mono openssl icu ]}
    runHook postInstall
  '';

  passthru = {
    updateScript = ./update.sh;
    # tests.smoke-test = nixosTests.readarr;
  };

  meta = with lib; {
    description = "Readarr is a ebook collection manager for Usenet and BitTorrent users";
    homepage = "https://readarr.com/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ camillemndn ];
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
  };
}
