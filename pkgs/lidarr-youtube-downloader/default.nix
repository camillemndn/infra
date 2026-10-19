{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  python3,
  ffmpeg,
  chromaprint,
}:

let
  # Not in nixpkgs; cover-art fallback.
  bing-image-downloader = python3.pkgs.buildPythonPackage rec {
    build-system = [ python3.pkgs.setuptools ];
    # No test suite.
    doCheck = false;

    meta = {
      description = "Python library to download bulk images from Bing.com";
      homepage = "https://github.com/gurugaurav/bing_image_downloader";
      license = lib.licenses.mit;
    };

    pname = "bing-image-downloader";
    pyproject = true;
    pythonImportsCheck = [ "bing_image_downloader" ];

    src = python3.pkgs.fetchPypi {
      inherit version;
      hash = "sha256-MKr3TWnepYGIBZoViPiZ+3CkuUj6K2oXIAeWE53UPV0=";
      pname = "bing_image_downloader";
    };

    version = "1.1.3";
  };

  pythonEnv = python3.withPackages (ps: [
    ps.flask
    ps.requests
    ps.yt-dlp
    ps.bgutil-ytdlp-pot-provider
    ps.ytmusicapi
    ps.mutagen
    ps.schedule
    ps.gunicorn
    bing-image-downloader
  ]);
in
stdenv.mkDerivation {
  dontBuild = true;
  # No build system: install the sources and wrap app.py.
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    appdir="$out/share/lidarr-youtube-downloader"
    mkdir -p "$appdir"
    cp -r ./*.py static templates tools "$appdir/"

    makeWrapper ${pythonEnv}/bin/python "$out/bin/lidarr-youtube-downloader" \
      --add-flags "$appdir/app.py" \
      --set PYTHONPATH "$appdir" \
      --prefix PATH : ${
        lib.makeBinPath [
          ffmpeg
          chromaprint
          pythonEnv
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "Self-hosted bridge that finds and downloads missing Lidarr albums from YouTube";
    homepage = "https://github.com/Angrido/Lidarr-YouTube-Downloader";
    license = lib.licenses.mit;
    mainProgram = "lidarr-youtube-downloader";
    platforms = lib.platforms.linux;
  };

  nativeBuildInputs = [ makeWrapper ];
  pname = "lidarr-youtube-downloader";

  # The album flow reads DOWNLOAD_DIR only from DOWNLOAD_PATH; fall back to the configured download_path.
  postPatch = ''
    substituteInPlace app.py processing.py \
      --replace-fail 'DOWNLOAD_DIR = os.getenv("DOWNLOAD_PATH", "")' \
        'DOWNLOAD_DIR = os.getenv("DOWNLOAD_PATH", "") or load_config().get("download_path", "")'
  '';

  src = fetchFromGitHub {
    hash = "sha256-fXapKSHJQbK0YzvqrcP+ccu1GFbhJj0oHFfDqrJGjl0=";
    owner = "Angrido";
    repo = "Lidarr-YouTube-Downloader";
    rev = "d9fd071d668610acb1848568318742a4a6881e7d";
  };

  version = "1.8.5-unstable-2026-07-22";
}
