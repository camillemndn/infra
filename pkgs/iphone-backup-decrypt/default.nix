{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "iphone-backup-decrypt";
  version = "0.11.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jsharkey13";
    repo = "iphone_backup_decrypt";
    tag = "v${version}";
    hash = "sha256-bUzKb57Nd52+EF7isNc4F4tfRSm4H853TeeVu81mjs4=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];
  propagatedBuildInputs = with python3.pkgs; [ pycryptodome ];

  passthru.optional-dependencies = with python3.pkgs; {
    fastpbkdf2 = [ fastpbkdf2 ];
  };

  pythonImportsCheck = [ "iphone_backup_decrypt" ];

  meta = {
    description = "Decrypt an encrypted iOS backup created by iTunes on Windows or MacOS";
    homepage = "https://github.com/jsharkey13/iphone_backup_decrypt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ camillemndn ];
    mainProgram = "iphone-backup-decrypt";
  };
}
