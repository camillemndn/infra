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
    version = "9.9.8d";

    src = fetchurl {
      url = "https://myriad-online.com/linux/harmony-assistant-${version}.0.run";
      hash = "sha256-kjSqEwOovRgIT52nyYn63vGDhxdqxYNFKhw9kxvKEbU=";
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

    meta = with lib; {
      description = "Un logiciel indispensable pour l'écriture et la composition musicale assistée par ordinateur";
      homepage = "https://www.myriad-online.com/fr/products/harmony.htm";
      license = licenses.unfree;
      maintainers = with maintainers; [ camillemndn ];
      platforms = with platforms; linux;
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
