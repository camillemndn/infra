{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  python3,
  makeWrapper,
  sqlite,
  mpv,
  killall,
  spotify-player,
  curl,
  nix-update-script,
}:

let
  python_env = python3.withPackages (
    p: with p; [
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
      (p.callPackage ../pyalsaaudio { })
    ]
  );
in

stdenv.mkDerivation rec {
  pname = "radiogaga";
  version = "0.1.0";

  front = buildNpmPackage {
    pname = "${pname}-front";
    inherit version src;
    sourceRoot = "source/front";
    npmDepsHash = "sha256-o0/aOc0kRpXEtYo3m2zs9ViGgXtiFLfnQGQ2z7CxGbc=";
    npmFlags = [ "--legacy-peer-deps" ];
    npmBuildFlags = [ "--prod" ];
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
    rev = "v${version}";
    hash = "sha256-Oa4GgKGuathZtiXc8POQAHHnb2eg/vvjrA+9UWqU7O0=";
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
      --prefix PATH : ${
        lib.makeBinPath [
          curl
          sqlite
          killall
          mpv
          python_env
        ]
      } \
      --chdir $out/share/${pname}
    makeWrapper ${python_env}/bin/gunicorn $out/bin/${pname} \
      --prefix PATH : ${
        lib.makeBinPath [
          curl
          sqlite
          killall
          mpv
          spotify-player
          python_env
        ]
      } \
      --add-flags "--bind 0.0.0.0:8000 radiogaga.wsgi:application" \
      --chdir $out/share/${pname}
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--flake" ]; };

  meta = with lib; {
    description = "Raspberry Pi Clock Radio";
    homepage = "https://github.com/camillemndn/radiogaga";
    license = licenses.mit;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.linux;
  };
}
