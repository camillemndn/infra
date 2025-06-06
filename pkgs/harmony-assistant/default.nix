{
  stdenv,
  lib,
  fetchurl,
  alsa-lib,
  freetype,
  fontconfig,
  xorg,
  expat,
  buildFHSEnv,
}:

let
  harmony-assistant-unwrapped = stdenv.mkDerivation rec {
    pname = "harmony-assistant";
    version = "9.9.9e";

    src = fetchurl {
      url = "https://myriad-online.com/linux/harmony-assistant-${version}.0.run";
      hash = "sha256-TQGENwLYoCY9THqUBKa+gz1ssOaOEm44OaX7m2gWPB0=";
    };

    unpackPhase = ''
      bash $src || true
    '';

    installPhase = ''
      mkdir -p $out/{bin,share/icons/hicolor/256x256/apps}
      cd harmony-assistant-${version}.0/InstallFiles
      cp -r "usr/bin/Harmony Assistant x64" "$out/bin/harmony-assistant"
      cp -r usr/share/* $out/share
      cp $out/share/{pixmaps/harmony-assistant.png,icons/hicolor/256x256/apps/}
      mv $out/share/{"Harmony Assistant",harmony-assistant}
      ln -s $out/share/harmony-assistant/Wacam/* $out/bin

      substituteInPlace "$out/share/applications/harmony-assistant.desktop" \
        --replace-fail "/usr/bin/Harmony Assistant" "harmony-assistant"
    '';

    dontFixup = true;

    meta = {
      description = "Un logiciel indispensable pour l'écriture et la composition musicale assistée par ordinateur";
      homepage = "https://www.myriad-online.com/fr/products/harmony.htm";
      license = lib.licenses.unfree;
      maintainers = with lib.maintainers; [ camillemndn ];
      platforms = lib.platforms.linux;
    };
  };
in

buildFHSEnv {
  name = "harmony-assistant";

  runScript = "harmony-assistant";

  targetPkgs = _: [ harmony-assistant-unwrapped ];

  multiPkgs = _: [
    alsa-lib
    freetype
    fontconfig
    xorg.libX11
    expat
  ];

  extraInstallCommands = ''
    cp -Lr ${harmony-assistant-unwrapped}/share $out
  '';

  inherit (harmony-assistant-unwrapped) meta;
}
