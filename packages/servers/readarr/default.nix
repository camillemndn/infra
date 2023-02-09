{ lib, stdenv, fetchurl, mono, libmediainfo, sqlite, curl, makeWrapper, icu, dotnetCorePackages, openssl, nixosTests }:

let
  os = if stdenv.isDarwin then "osx" else "linux";
  arch = {
    x86_64-linux = "x64";
    aarch64-linux = "arm64";
    x86_64-darwin = "x64";
  }."${stdenv.hostPlatform.system}" or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  hash = {
    x64-linux_hash = "sha256-pdcdCvc594Cr3v9J7//ku6N38tx3KU06UhEZYXwqMuk=";
    arm64-linux_hash = lib.fakeHash;
    x64-osx_hash = lib.fakeHash;
  }."${arch}-${os}_hash";

in
stdenv.mkDerivation rec {
  pname = "readarr";
  version = "0.1.2.1558";

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
    tests.smoke-test = nixosTests.readarr;
  };

  meta = with lib; {
    description = "Readarr is a ebook collection manager for Usenet and BitTorrent users";
    homepage = "https://readarr.com/";
    license = licenses.gpl3Only;
    # maintainers = with maintainers; [ camillemndn ];
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
  };
}
