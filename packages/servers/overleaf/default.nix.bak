{ lib
, buildNpmPackage
, fetchFromGitHub
, nodejs-16_x
}:

(buildNpmPackage.override { nodejs = nodejs-16_x; }) rec {
  pname = "overleaf";
  version = "unstable-2023-02-11";

  src = fetchFromGitHub {
    owner = "overleaf";
    repo = "overleaf";
    rev = "b0bd070018d181696092dec3d4431181aad17b01";
    hash = "sha256-PazUG3qcc9Utu6pYjppXe5A2N6pqZ+D42o7BDLzyJfQ=";
  };

  sourceRoot = "source/services/web";

  npmDepsHash = "sha256-9y+zEnhDTyQWEkPbRHw9Tw/FMMRgH73o8RJ+INjx30E=";

  npmFlags = [ "--prefix ./" "--legacy-peer-deps" "--loglevel=verbose" "--include dev" "--production=false" ];

  postPatch = ''
    install -m644 ${./package-lock.json} package-lock.json
    cp ${./package.json} package.json
  '';

  npmBuildScript = "webpack:production";

  npmRebuildFlags = [ ];

  meta = with lib; {
    description = "A web-based collaborative LaTeX editor";
    homepage = "https://github.com/overleaf/overleaf/tree/main/services/web";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ];
  };
}
