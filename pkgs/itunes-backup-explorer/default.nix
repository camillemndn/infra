{
  lib,
  maven,
  jdk,
  fetchFromGitHub,
  makeWrapper,
  wrapGAppsHook3,
  copyDesktopItems,
  makeDesktopItem,
}:

let
  jdk' = jdk.override { enableJavaFX = true; };
in

maven.buildMavenPackage rec {
  pname = "itunes-backup-explorer";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "MaxiHuHe04";
    repo = "iTunes-Backup-Explorer";
    rev = "v${version}";
    hash = "sha256-i7znPQjz+39HEk9Iqgw2Rarlw0EoMNTQ/wSK29I9uZU=";
  };

  mvnJdk = jdk';
  mvnHash = "sha256-DRXJI7HcoTH7mhiHQ4ni9sHVustMYpbgygiXUBWGn38=";

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
    copyDesktopItems
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "itunes-backup-explorer";
      desktopName = "iTunes Backup Explorer";
      exec = "itunes-backup-explorer";
    })
  ];

  postFixup = ''
    mkdir -p $out/bin $out/share/
    install -Dm644 target/itunes-backup-explorer-${version}-SNAPSHOT-jar-with-dependencies.jar $out/share/itunes-backup-explorer.jar

    makeWrapper ${jdk'}/bin/java $out/bin/itunes-backup-explorer \
      "''${gappsWrapperArgs[@]}" \
      --add-flags "-jar $out/share/itunes-backup-explorer.jar"
  '';
  meta = with lib; {
    description = "A graphical tool that can extract and replace files from encrypted and non-encrypted iOS backups";
    homepage = "https://github.com/MaxiHuHe04/iTunes-Backup-Explorer";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "itunes-backup-explorer";
    platforms = platforms.all;
  };
}
