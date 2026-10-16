{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  aiofiles,
  pycryptodome,
}:

buildHomeAssistantComponent rec {
  owner = "robhofmann";
  domain = "gree";
  version = "3.3.2";

  src = fetchFromGitHub {
    owner = "RobHofmann";
    repo = "HomeAssistant-GreeClimateComponent";
    tag = "${version}";
    hash = "sha256-DeSJax2ptq0W158YIDxZe7uCsrambHX2s3qjL9QQVZc=";
  };

  dependencies = [
    aiofiles
    pycryptodome
  ];

  meta = {
    changelog = "https://https://github.com/RobHofmann/HomeAssistant-GreeClimateComponent/releases/tag/${src.tag}";
    description = "Home Assistant Integration for Gree";
    homepage = "https://https://github.com/RobHofmann/HomeAssistant-GreeClimateComponent";
    maintainers = with lib.maintainers; [ camillemndn ];
    license = lib.licenses.mit;
  };
}
