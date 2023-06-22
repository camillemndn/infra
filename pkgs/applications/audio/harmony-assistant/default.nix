{ stdenv
, lib
, fetchurl
, alsa-lib
, freetype
, fontconfig
, libX11
, expat
, buildFHSEnv
}:

let
  harmony-assistant-unwrapped = stdenv.mkDerivation rec {
    pname = "harmony-assistant";
    version = "9.9.6c";

    src = fetchurl {
      url = "https://www.myriad-online.com/linux/harmony-assistant-${version}.0.run";
      sha256 = "sha256-2TYp/pkhvHdgDBii7ejSrxRqbzdahJtB1b21OoMpDD4=";
    };

    unpackPhase = ''
      bash $src || true
    '';

    installPhase = ''
      mkdir -p $out/{bin,share}
      cd harmony-assistant-${version}.0/InstallFiles
      cp -r "usr/bin/Harmony Assistant x64" "$out/bin/harmony-assistant"
      cp -r usr/share/* $out/share
      mv $out/share/{"Harmony Assistant",harmony-assistant}
    '';

    dontFixup = true;

    meta = with lib; {
      description = "Un logiciel indispensable pour l'écriture et la composition musicale assistée par ordinateur";
      homepage = "https://www.myriad-online.com/fr/products/harmony.htm";
      # license = licenses.agpl3Only;
      maintainers = with maintainers; [ camillemndn ];
      platforms = with platforms; linux;
    };
  };
in

buildFHSEnv {
  name = "harmony-assistant";

  runScript = "harmony-assistant";

  targetPkgs = pkgs: [ harmony-assistant-unwrapped ];

  multiPkgs = pkgs: [ alsa-lib freetype fontconfig libX11 expat ];

  extraInstallCommands = ''
    mkdir -p $out/share
    cp -Lr ${harmony-assistant-unwrapped}/share/* $out/share
    chmod -R +w $out/share
    ls -all $out/share
  '';

  meta = harmony-assistant-unwrapped.meta;
}
