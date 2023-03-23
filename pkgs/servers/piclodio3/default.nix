{ lib
, stdenv
, buildNpmPackage
, fetchFromGitHub
, python3
, makeWrapper
, sqlite
}:

let
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
      #pyalsaaudio
      django-cors-headers
      gunicorn
      pyyaml
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
    #sed -i "s/^\([A-Z0-9_]*\) = \(.*\)/\1_DEFAULT = \2\n\1 = os.getenv('\1', default=\1_DEFAULT)/" \
    sed -i "s/\(BASE_DIR\) = \(.*\)/\1_DEFAULT = \2\n\1 = os.getenv('\1', default=\1_DEFAULT)/" \
      back/piclodio3/settings.py
    #cat back/piclodio3/settings.py
    #cp zefzoeijj  
  '';

  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share
    cp -r . $out/share/${pname}
    ln -s $front/share/${pname}-front $out/share
  '';

  postFixup = ''
    makeWrapper ${python_env}/bin/python $out/bin/${pname}-migrations \
      --prefix PATH : ${lib.makeBinPath [ sqlite ]} \
      --add-flags 'manage.py showmigrations' \
      --chdir $out/share/${pname}/back
    makeWrapper ${python_env}/bin/gunicorn $out/bin/${pname} \
      --prefix PATH : ${lib.makeBinPath [ sqlite ]} \
      --add-flags '--bind 0.0.0.0:8000 piclodio3.wsgi:application' \
      --chdir $out/share/${pname}/back
  '';

  meta = with lib; {
    description = "Raspberry Pi Clock Radio";
    homepage = "https://github.com/Sispheor/piclodio3/";
    license = licenses.mit;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.all;
  };
}
