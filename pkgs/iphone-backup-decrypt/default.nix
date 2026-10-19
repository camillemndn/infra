{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage rec {
  meta = {
    description = "Decrypt an encrypted iOS backup created by iTunes on Windows or MacOS";
    homepage = "https://github.com/jsharkey13/iphone_backup_decrypt";
    license = lib.licenses.mit;
    mainProgram = "iphone-backup-decrypt";
    maintainers = with lib.maintainers; [ camillemndn ];
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  passthru.optional-dependencies = with python3.pkgs; {
    fastpbkdf2 = [ fastpbkdf2 ];
  };

  pname = "iphone-backup-decrypt";
  propagatedBuildInputs = with python3.pkgs; [ pycryptodome ];
  pyproject = true;
  pythonImportsCheck = [ "iphone_backup_decrypt" ];

  src = fetchFromGitHub {
    hash = "sha256-bUzKb57Nd52+EF7isNc4F4tfRSm4H853TeeVu81mjs4=";
    owner = "jsharkey13";
    repo = "iphone_backup_decrypt";
    tag = "v${version}";
  };

  version = "0.11.2";
}
