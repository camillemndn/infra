{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  makeWrapper,
  iphone-backup-decrypt,
  nix-update-script,
}:

let
  python_env = python3.withPackages (_: [ iphone-backup-decrypt ]);
in

stdenv.mkDerivation {
  pname = "dump-iphone-backup";
  version = "0-unstable-2023-07-22";

  src = fetchFromGitHub {
    owner = "PeterUpfold";
    repo = "dump-iphone-backup";
    rev = "66833eab45b8a72260e0974dc904a23e47babf16";
    hash = "sha256-1CBQ7cfoXEvKvQ/CE+Rj8OqVrP8Z8jFRDTXnu73+RUA=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/{bin,share}
    cp dump-iphone-backup.py $out/share
  '';

  postFixup = ''
    makeWrapper ${python_env}/bin/python $out/bin/dump-iphone-backup \
      --add-flags "$out/share/dump-iphone-backup.py" \
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Dump an encrypted iPhone backup to a folder for analysis of any artifacts, organised by domain and path of the source file";
    homepage = "https://github.com/PeterUpfold/dump-iphone-backup";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ camillemndn ];
    mainProgram = "dump-iphone-backup";
    platforms = lib.platforms.all;
  };
}
