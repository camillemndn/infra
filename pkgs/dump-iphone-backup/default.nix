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
  version = "0-unstable-2026-09-13";
  src = fetchFromGitHub {
    owner = "PeterUpfold";
    repo = "dump-iphone-backup";
    rev = "031f7c553a60bb6fe5943f1b997e755e30743e2c";
    hash = "sha256-ZybbWiQMRDM3EswC9OpPBeQbm8KLPHmt3dKvoRnOVtw=";
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
