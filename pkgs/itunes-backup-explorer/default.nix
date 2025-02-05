{
  lib,
  maven,
  jdk23,
  fetchFromGitHub,
  makeWrapper,
  wrapGAppsHook3,
  copyDesktopItems,
  makeDesktopItem,
  nix-update-script,
}:

let
  jdk' = jdk23.override { enableJavaFX = true; };
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
  mvnHash = "sha256-zrdm4f73xF2od3JBFs4VOg0bg5mfpccIzrF7GEzB1LA=";

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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A graphical tool that can extract and replace files from encrypted and non-encrypted iOS backups";
    homepage = "https://github.com/MaxiHuHe04/iTunes-Backup-Explorer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ camillemndn ];
    mainProgram = "itunes-backup-explorer";
    platforms = [ "x86_64-linux" ];
  };
}
