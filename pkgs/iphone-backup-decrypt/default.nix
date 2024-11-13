{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage {
  pname = "iphone-backup-decrypt";
  version = "0.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "KnugiHK";
    repo = "iphone_backup_decrypt";
    rev = "609b6297a84354086d53a64b3dfbe36eebcc84bd";
    hash = "sha256-2w0sSFpxIe8eT4wkAL+5E1+34/ExlY6nY+8JsjjbOkI=";
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

  meta = with lib; {
    description = "Decrypt an encrypted iOS backup created by iTunes on Windows or MacOS";
    homepage = "https://github.com/jsharkey13/iphone_backup_decrypt";
    license = licenses.mit;
    maintainers = with maintainers; [ camillemndn ];
    mainProgram = "iphone-backup-decrypt";
  };
}
