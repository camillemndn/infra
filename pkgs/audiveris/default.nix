{
  lib,
  fetchFromGitHub,
  git,
  makeWrapper,
  jre,
  tesseract,
  freetype,
  copyDesktopItems,
  makeDesktopItem,
  coreutils,
  findutils,
  gnused,
}:

let
  gradle2nix =
    import (fetchTarball "https://github.com/milahu/gradle2nix/archive/pull69-patch1.tar.gz")
      { };

  fixVersion = str: builtins.head (builtins.match "([^-]*-?[^-]*).*" str);
in

gradle2nix.buildGradlePackage rec {
  pname = "audiveris";
  version = "5.4-alpha-3";

  src = fetchFromGitHub {
    owner = "Audiveris";
    repo = "audiveris";
    rev = version;
    hash = "sha256-X+hhPlm+D+kJ6B35FJMj+E5mbcaAZpZzHQs/tPTPDLw=";
    leaveDotGit = true;
  };

  postPatch = ''
    find app/src/main/java/org/audiveris/omr -type f -exec sed -i {} -e 's/com.jgoodies.looks.plastic.Plastic3DLookAndFeel/com.sun.java.swing.plaf.gtk.GTKLookAndFeel/g' \;
  '';

  buildInputs = [
    git
    makeWrapper
  ];

  nativeBuildInputs = [ copyDesktopItems ];

  lockFile = ./gradle.lock;

  installPhase = ''
    tar -xf app/build/distributions/app-${fixVersion version}.tar
    install -m 0755 -D app-${fixVersion version}/bin/Audiveris $out/bin/Audiveris
    cp -r app-${fixVersion version}/lib $out
    install -m 0644 -D app/res/icon-256.png $out/share/icons/hicolor/256x256/apps/org.audiveris.audiveris.png
    install -m 0644 -D app/res/icon-64.png $out/share/icons/hicolor/64x64/apps/org.audiveris.audiveris.png
    for size in 48 32 24 16; do
      install -m 0644 -D $src/app/src/main/java/org/audiveris/omr/ui/resources/icon-$size.png \
        $out/share/icons/hicolor/"$size"x"$size"/apps/org.audiveris.audiveris.png
    done
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "org.audiveris.audiveris";
      desktopName = "Audiveris";
      genericName = "Optical Music Recognition (OMR)";
      exec = "Audiveris";
      type = "Application";
      icon = "org.audiveris.audiveris";
      comment = "Convert sheet music to XML";
      categories = [
        "Music"
        "Scanning"
        "AudioVideo"
      ];
      keywords = [
        "lilypond"
        "editor"
        "sheet music"
        "java"
      ];
    })
  ];

  postFixup = ''
    wrapProgram $out/bin/Audiveris \
      --set JAVA_HOME ${jre}/lib/openjdk \
      --set TESSDATA_PREFIX ${tesseract}/share/tessdata \
      --set PATH ${
        lib.makeBinPath [
          freetype
          coreutils
          findutils
          gnused
        ]
      }
  '';

  meta = {
    description = "Latest generation of Audiveris OMR engine";
    homepage = "https://github.com/Audiveris/audiveris/";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ camillemndn ];
    mainProgram = "Audiveris";
    platforms = lib.platforms.linux;
  };
}
