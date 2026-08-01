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
  # Not in nixpkgs; pure-Python, no dependencies. Used for cover-art fallback.
  bing-image-downloader = python3.pkgs.buildPythonPackage rec {
    pname = "bing-image-downloader";
    version = "1.1.3";
    pyproject = true;

    src = python3.pkgs.fetchPypi {
      pname = "bing_image_downloader";
      inherit version;
      hash = "sha256-MKr3TWnepYGIBZoViPiZ+3CkuUj6K2oXIAeWE53UPV0=";
    };

    build-system = [ python3.pkgs.setuptools ];

    # No test suite; the package only reaches out to the network at runtime.
    doCheck = false;
    pythonImportsCheck = [ "bing_image_downloader" ];

    meta = {
      description = "Python library to download bulk images from Bing.com";
      homepage = "https://github.com/gurugaurav/bing_image_downloader";
      license = lib.licenses.mit;
    };
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
  pname = "lidarr-youtube-downloader";
  version = "1.8.5-unstable-2026-07-22";

  src = fetchFromGitHub {
    owner = "Angrido";
    repo = "Lidarr-YouTube-Downloader";
    rev = "d9fd071d668610acb1848568318742a4a6881e7d";
    hash = "sha256-fXapKSHJQbK0YzvqrcP+ccu1GFbhJj0oHFfDqrJGjl0=";
  };

  nativeBuildInputs = [ makeWrapper ];

  # The album-download flow reads DOWNLOAD_DIR only from the DOWNLOAD_PATH env
  # var, ignoring the download_path saved in config.json / the settings UI
  # (unlike lidarr_path). Fall back to the configured value so the UI setting
  # works as the app's own error message promises.
  postPatch = ''
    substituteInPlace app.py processing.py \
      --replace-fail 'DOWNLOAD_DIR = os.getenv("DOWNLOAD_PATH", "")' \
        'DOWNLOAD_DIR = os.getenv("DOWNLOAD_PATH", "") or load_config().get("download_path", "")'
  '';

  # Plain collection of Flask modules launched via `python app.py`; there is
  # no build system, so just install the sources and wrap the entrypoint.
  dontConfigure = true;
  dontBuild = true;

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
}
