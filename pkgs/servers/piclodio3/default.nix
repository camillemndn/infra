{ lib
, stdenv
, buildNpmPackage
, fetchFromGitHub
, python3
, makeWrapper
, sqlite
, callPackage
, mpg123
, killall
, curl
}:

let
  customPackages = callPackage ../../top-level/python-packages.nix { };
  python_env = python3.withPackages
    (p: with p; [
      django
      django-filter
      djangorestframework
      markdown
      drf-yasg
      apscheduler
      sqlalchemy
      psutil
      django-cors-headers
      gunicorn
      pyyaml
      packaging
      customPackages.pyalsaaudio
    ]);
in

stdenv.mkDerivation rec {
  pname = "piclodio3";
  version = "unstable-2022-02-13";

  front = buildNpmPackage {
    pname = "${pname}-front";
    inherit version src;
    sourceRoot = "source/front";
    npmDepsHash = "sha256-AA8EkXotHT6Gnqvs7JWyEzbWm0R4YhC/vKKHjbSqz7A=";
    npmFlags = [ "--legacy-peer-deps" ];
    npmBuildFlags = [ "--prod" ];
    NODE_OPTIONS = "--openssl-legacy-provider";

    postPatch = ''
      rm package-lock.json
      cp ${./package-lock.json} package-lock.json
      sed -i "s/Piclodio/RadioGaGa | Hi my love!/g" \
        src/app/top-bar/top-bar.component.html 
      sed -i "s/Piclodio3Front/RadioGaGa/g" \
        src/index.html
    '';

    installPhase = ''
      mkdir -p $out/share
      cp -r dist/${pname}-front $out/share
    '';
  };

  src = fetchFromGitHub {
    owner = "Sispheor";
    repo = "piclodio3";
    rev = "5ca7f2637f9bf1070c5c2e21b2198bc878b11b28";
    hash = "sha256-yUrFnBBPK2ByIGImwZsNQW8hNC+RwIO9iBnixS2DvDo=";
  };

  postPatch = ''
    sed -i "s/\(BASE_DIR\) = \(.*\)/\1_DEFAULT = \2\n\1 = os.getenv('\1', default=\1_DEFAULT)/" \
      back/piclodio3/settings.py
    sed -i "s|/usr/bin/mplayer|mpg123|g" \
      back/utils/player_manager.py
    sed -i "s|mplayer|mpg123|g" \
      back/utils/player_manager.py
    patchShebangs .
  '';

  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share
    cp -r back $out/share/${pname}
    ln -s $front/share/${pname}-front $out/share
  '';

  postFixup = ''
    makeWrapper $out/share/${pname}/entrypoint.sh $out/bin/${pname} \
      --prefix PATH : ${lib.makeBinPath [ curl sqlite killall mpg123 python_env ]} \
      --chdir $out/share/${pname}
  '';

  meta = with lib; {
    description = "Raspberry Pi Clock Radio";
    homepage = "https://github.com/Sispheor/piclodio3/";
    license = licenses.mit;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.all;
  };
}
