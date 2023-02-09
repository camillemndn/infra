{ lib, stdenv, python3, pkgs, makeWrapper, fetchFromGitLab }:

let
  python_env = python3.withPackages
    (p: with p; [
      apprise
      beautifulsoup4
      cherrypy
      deluge-client
      html5lib
      httpagentparser
      httplib2
      Mako
      pillow
      pyopenssl
      pypdf3
      python-magic
      requests
      thefuzz
      levenshtein
      urllib3
      webencodings
      magic
    ]);
in

stdenv.mkDerivation rec {
  pname = "lazylibrarian";
  version = "2022.12.5";

  src = fetchFromGitLab {
    owner = "LazyLibrarian";
    repo = "LazyLibrarian";
    rev = "6b5daeb0d863162e0bdbeb14d10b46714e0ad528";
    hash = "sha256-ebLpi5IG/sVy23KvZfsAdWaGFwaBJy2KDd6tS5R00QE=";
  };

  buildInputs = [ makeWrapper ];

  patches = [ ./deps.patch ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share
    cp -r . $out/share
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${python_env}/bin/python $out/bin/lazylibrarian \
      --add-flags $out/share/LazyLibrarian.py \
      --chdir $out/share/
  '';

  meta = with lib; {
    description = "LazyLibrarian is a SickBeard, CouchPotato, Headphones-like application for ebooks, audiobooks and magazines";
    homepage = "https://gitlab.com/LazyLibrarian/LazyLibrarian";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.all;
  };
}
