{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchNpmDeps,
  npmHooks,
  nodejs,
  python3,
  makeWrapper,
  curl,
  killall,
  mpv,
  nix-update-script,
  pyalsaaudio,
  spotify-player,
  sqlite,
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
      pyalsaaudio
    ]
  );
in

stdenv.mkDerivation rec {
  pname = "radiogaga";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "camillemndn";
    repo = "radiogaga";
    rev = "v${version}";
    hash = "sha256-0Q4aFcJR8w25Ah5TRCekXYbWBIoaVXNKQFYSzYVqzJI=";
  };

  npmRoot = "front";

  npmDeps = fetchNpmDeps {
    name = "${pname}-npm-deps-${version}";
    src = "${src}/${npmRoot}";
    hash = "sha256-o0/aOc0kRpXEtYo3m2zs9ViGgXtiFLfnQGQ2z7CxGbc=";
  };

  postPatch = ''
    sed -i "s/\(BASE_DIR\) = \(.*\)/\1_DEFAULT = \2\n\1 = os.getenv('\1', default=\1_DEFAULT)/" \
      back/radiogaga/settings.py

    sed -i "s/RadioGaGa/RadioGaGa | Hi my love!/g" \
      front/src/app/top-bar/top-bar.component.html 
  '';

  nativeBuildInputs = [
    python3
    npmHooks.npmConfigHook
    nodejs
  ];

  buildInputs = [ makeWrapper ];

  buildPhase = ''
    pushd front
    npm run build --prod
    popd
  '';

  installPhase = ''
    mkdir $out
    cp -r back $out/lib
    cp -r front/dist/radiogaga-front $out/share
  '';

  postFixup = ''
    makeWrapper $out/lib/entrypoint.sh $out/bin/radiogaga-init \
      --chdir $out/lib \
      --prefix PATH : ${
        lib.makeBinPath [
          curl
          killall
          mpv
          python_env
          sqlite
        ]
      }

    makeWrapper ${python_env}/bin/gunicorn $out/bin/radiogaga \
      --add-flags "--bind 0.0.0.0:8000 radiogaga.wsgi:application" \
      --chdir $out/lib \
      --prefix PATH : ${
        lib.makeBinPath [
          curl
          killall
          mpv
          python_env
          spotify-player
          sqlite
        ]
      }
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Raspberry Pi Clock Radio";
    homepage = "https://github.com/camillemndn/radiogaga";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ camillemndn ];
    platforms = lib.platforms.linux;
    mainProgram = "whatsapp-chat-exporter";
  };
}
