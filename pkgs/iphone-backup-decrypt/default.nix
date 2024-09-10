{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "iphone-backup-decrypt";
  version = "0.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jsharkey13";
    repo = "iphone_backup_decrypt";
    rev = "v${version}";
    hash = "sha256-hJ45R/F3NRn24GKWvGx5N10/ZB6aC8blrIgDEN40FRY=";
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
