{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  aiofiles,
  pycryptodome,
}:

buildHomeAssistantComponent rec {
  dependencies = [
    aiofiles
    pycryptodome
  ];

  domain = "gree";

  meta = {
    changelog = "https://https://github.com/RobHofmann/HomeAssistant-GreeClimateComponent/releases/tag/${src.tag}";
    description = "Home Assistant Integration for Gree";
    homepage = "https://https://github.com/RobHofmann/HomeAssistant-GreeClimateComponent";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ camillemndn ];
  };

  owner = "robhofmann";

  src = fetchFromGitHub {
    hash = "sha256-DeSJax2ptq0W158YIDxZe7uCsrambHX2s3qjL9QQVZc=";
    owner = "RobHofmann";
    repo = "HomeAssistant-GreeClimateComponent";
    tag = "${version}";
  };

  version = "3.3.2";
}
