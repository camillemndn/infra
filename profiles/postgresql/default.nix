{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.services.postgresql.enable {
    services.postgresql.package = pkgs.postgresql_17;

    environment.systemPackages =
      let
        newPostgres = pkgs.postgresql_17.withPackages (_pp: [ ]);

        upgrade-pg-cluster = pkgs.writeScriptBin "upgrade-pg-cluster" ''
          set -eux
          # XXX it's perhaps advisable to stop all services that depend on postgresql
          systemctl stop postgresql

          export NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"

          export NEWBIN="${newPostgres}/bin"

          export OLDDATA="${config.services.postgresql.dataDir}"
          export OLDBIN="${config.services.postgresql.package}/bin"

          install -d -m 0700 -o postgres -g postgres "$NEWDATA"
          cd "$NEWDATA"
          sudo -u postgres $NEWBIN/initdb -D "$NEWDATA"

          sudo -u postgres $NEWBIN/pg_upgrade \
            --old-datadir "$OLDDATA" --new-datadir "$NEWDATA" \
            --old-bindir $OLDBIN --new-bindir $NEWBIN \
            "$@"
        '';
      in
      [ upgrade-pg-cluster ];
  };
}
