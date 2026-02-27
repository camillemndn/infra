{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "mmt";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "konradit";
    repo = "mmt";
    rev = "v${version}";
    hash = "sha256-Se5mVj2+QWggaoScfLTLb3sRCI/mDAWYZX/5WTn9syQ=";
  };

  vendorHash = "sha256-obrRLICBpI8dxojaHm3SY+B2sBSTbq/dteUvTNTtwpE=";

  ldflags = [
    "-s"
    "-w"
  ];

  env = {
    CGO_CFLAGS = "-Wno-undef-prefix";
  };

  doCheck = false;

  meta = {
    description = "Media Management Tool - make importing videos/photos from GoPro and other action cameras/drones a little bit more bearable";
    homepage = "https://github.com/konradit/mmt";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "mmt";
  };
}
