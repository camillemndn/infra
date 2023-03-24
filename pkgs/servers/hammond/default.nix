{ pkgs, stdenv, lib, fetchFromGitHub, buildGoModule, go, nodejs, yarn, buildNpmPackage }:

let
  version = "2022.07.26";

  src = fetchFromGitHub {
    owner = "akhilrex";
    repo = "hammond";
    rev = "84cba2c7f26f6d3f81c49b132110b24ac97c7b49";
    sha256 = "sha256-kBL9qRpYvdyt98Jaesk2QLpbGXFTs1oAc6I/v36a4nE=";
  };

  meta = with lib; {
    description = "Hammond is a self hosted vehicle management system to track fuel and other expenses related to all of your vehicles.";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ camillemndn ];
    platforms = platforms.linux;
  };

  hammond-backend = buildGoModule {
    name = "hammond-backend-${version}";
    inherit src version meta;
    modRoot = "server";
    vendorSha256 = "sha256-wb36Ppt8ZuH4srfpaCIfYLrk/VQK1esinM778FlfknM=";

    ldflags = [
      "-X main.version=${version}"
      "-X main.goVersion=${lib.getVersion go}"
    ];
  };

  hammond-frontend = buildNpmPackage {
    name = "hammond-frontend-${version}";
    inherit src version meta;
    sourceRoot = "source/ui";
    npmDepsHash = "sha256-W1M6tta56iUn2a+oBW3Qayn9TguBBnNPwaCcblOBGMg=";

    patches = [ ./lock.patch ];

    postPatch = ''
      substituteInPlace package.json --replace '"version": "0.0.0"' '"version": "${version}"'
    '';

    nativeBuildInputs = [ nodejs yarn ];

    npmFlags = [ "--legacy-peer-deps" ];

    npmRebuildFlags = [ ];

    preBuild = ''
      export NODE_OPTIONS=--openssl-legacy-provider
    '';

    npmBuildScript = "build:ci";

    installPhase = ''
      cd dist
      ls -all
      mkdir $out
      cp -r * $out
    '';
  };
in

stdenv.mkDerivation rec {
  inherit src version meta;
  pname = "hammond";

  src1 = hammond-backend;
  src2 = hammond-frontend;

  installPhase = ''
    mkdir -p $out/bin
    shopt -s dotglob
    cp $src1/bin/hammond $out/bin
    mkdir $out/dist 
    cp -r $src2/* $out/dist    
  '';
}
