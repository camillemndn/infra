{
  lib,
  fetchgit,
  pkgs,
  jre,
  runtimeShell,
}:

let
  buildGradle = pkgs.callPackage ./gradle-env.nix { };
in

buildGradle rec {
  pname = "audiveris";
  version = "5.3-alpha";

  src = fetchgit {
    url = "https://github.com/Audiveris/audiveris";
    rev = "5.3.1";
    hash = "sha256-/g8eolzAnYaSqKGUa7I4Mad0BCu5SVU9YkX5UzygQuM=";
    leaveDotGit = true;
  };

  patches = [ ./theme.patch ];

  envSpec = ./gradle-env.json;

  gradleFlags = [ "build -Dorg.gradle.project.buildDir=$TMP" ];

  installPhase = ''
    mkdir -p $out
    tar -xf $TMP/distributions/Audiveris-${version}.tar -C $TMP
    cp -r $TMP/Audiveris-${version}/* $out
    ls -all $out/bin
    cd $out/bin

    cat > "$out/bin/audiveris" << EOF
    #!${runtimeShell}

    export JAVA_HOME=${jre}/lib/openjdk
    export TESSDATA_PREFIX=${pkgs.tesseract}/share
    $out/bin/Audiveris 
    EOF
    chmod a+x "$out/bin/audiveris"
  '';

  propagatedBuildInputs = with pkgs; [
    tesseract
    freetype
    git
    jre
  ];

  meta = with lib; {
    description = "Latest generation of Audiveris OMR engine";
    homepage = "https://github.com/Audiveris/audiveris";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ camillemndn ];
    platforms = with platforms; linux ++ darwin;
  };
}
