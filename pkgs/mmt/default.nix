{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  doCheck = false;

  env = {
    CGO_CFLAGS = "-Wno-undef-prefix";
  };

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Media Management Tool - make importing videos/photos from GoPro and other action cameras/drones a little bit more bearable";
    homepage = "https://github.com/konradit/mmt";
    license = lib.licenses.asl20;
    mainProgram = "mmt";
    maintainers = with lib.maintainers; [ ];
  };

  pname = "mmt";

  src = fetchFromGitHub {
    hash = "sha256-Se5mVj2+QWggaoScfLTLb3sRCI/mDAWYZX/5WTn9syQ=";
    owner = "konradit";
    repo = "mmt";
    rev = "v${version}";
  };

  vendorHash = "sha256-obrRLICBpI8dxojaHm3SY+B2sBSTbq/dteUvTNTtwpE=";
  version = "2.0";
}
