{ lib
, stdenv
, fetchgit
, pkgs
, jre
, runtimeShell
}:

let
  buildGradle = pkgs.callPackage ./gradle-env.nix { };
  version = "5.3-alpha";
in

buildGradle {
  pname = "audiveris";
  inherit version;

  src = fetchgit {
    url = "https://github.com/Audiveris/audiveris";
    rev = "5.2.5";
    hash = "sha256-/WJz00muu+gqXodV6G+zqQ/o6hoYZPqzMecEOg62XQg=";
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

  propagatedBuildInputs = with pkgs; [ tesseract freetype git jre ];

  meta = with lib; {
    description = "Latest generation of Audiveris OMR engine";
    homepage = "https://github.com/Audiveris/audiveris";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ camillemndn ];
    platforms = with platforms; linux ++ darwin;
  };
}
