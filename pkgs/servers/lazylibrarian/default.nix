{ lib, stdenv, python3, makeWrapper, fetchFromGitLab }:

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
    rev = "862c2c86a0aa9a114ae3113d95c0a9278371abb0";
    hash = "sha256-+prd8OtqBDH/9JDTKpavmV0C3ELGvGlUtsTkHPwMcDw=";
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
    platforms = platforms.linux;
  };
}
