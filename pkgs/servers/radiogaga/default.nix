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
, spotify-tui
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
  pname = "radiogaga";
  version = "unstable-2023-04-24";

  front = buildNpmPackage {
    pname = "${pname}-front";
    inherit version src;
    sourceRoot = "source/front";
    npmDepsHash = "sha256-o0/aOc0kRpXEtYo3m2zs9ViGgXtiFLfnQGQ2z7CxGbc=";
    npmFlags = [ "--legacy-peer-deps" ];
    npmBuildFlags = [ "--prod" ];
    #NODE_OPTIONS = "--openssl-legacy-provider";
    nativeBuildInputs = [ python3 ];

    postPatch = ''
      sed -i "s/RadioGaGa/RadioGaGa | Hi my love!/g" \
        src/app/top-bar/top-bar.component.html 
    '';

    installPhase = ''
      mkdir -p $out/share
      cp -r dist/${pname}-front $out/share
    '';
  };

  src = fetchFromGitHub {
    owner = "camillemndn";
    repo = "radiogaga";
    rev = "9165b84fca4d5bc900805c5c4cb9882055f06328";
    hash = "sha256-VTDZwNuFm9MPAMHPsXxXMi1t9Gxi/VVokDpCM/rzdpE=";
  };

  postPatch = ''
    sed -i "s/\(BASE_DIR\) = \(.*\)/\1_DEFAULT = \2\n\1 = os.getenv('\1', default=\1_DEFAULT)/" \
      back/radiogaga/settings.py
    patchShebangs .
  '';

  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share
    cp -r back $out/share/${pname}
    ln -s $front/share/${pname}-front $out/share
  '';

  postFixup = ''
    makeWrapper $out/share/${pname}/entrypoint.sh $out/bin/${pname}-init \
      --prefix PATH : ${lib.makeBinPath [ curl sqlite killall mpg123 python_env ]} \
      --chdir $out/share/${pname}
    makeWrapper ${python_env}/bin/gunicorn $out/bin/${pname} \
      --prefix PATH : ${lib.makeBinPath [ curl sqlite killall mpg123 spotify-tui python_env ]} \
      --add-flags "--bind 0.0.0.0:8000 radiogaga.wsgi:application" \
      --chdir $out/share/${pname}
  '';

  meta = with lib; {
    description = "Raspberry Pi Clock Radio";
    homepage = "https://github.com/camillemndn/radiogaga";
    license = licenses.mit;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.linux;
  };
}
