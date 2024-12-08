{
  lib,
  python3,
  fetchFromGitHub,
  iphone-backup-decrypt,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "whatsapp-chat-exporter";
  version = "0.10.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "KnugiHK";
    repo = "Whatsapp-Chat-Exporter";
    rev = version;
    hash = "sha256-TPXQaWnUy+blTS+Tz84K6cxJu4+dLbT2Dl9SKqlhDHY=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = [
    python3.pkgs.jinja2
    python3.pkgs.bleach
    iphone-backup-decrypt
  ];

  meta = with lib; {
    description = "A customizable Android and iOS/iPadOS WhatsApp database parser that will give you the history of your WhatsApp conversations in HTML and JSON. Android Backup Crypt12, Crypt14, Crypt15, and new schema supported";
    homepage = "https://github.com/KnugiHK/Whatsapp-Chat-Exporter";
    license = with licenses; [
      bsd3
      mit
    ];
    maintainers = with maintainers; [ camillemndn ];
    mainProgram = "whatsapp-chat-exporter";
  };
}
