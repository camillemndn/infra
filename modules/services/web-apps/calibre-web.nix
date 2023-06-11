{ config, lib, pkgs, options, ... }:

with lib;

let
  enabledServers = filterAttrs (_: conf: conf.enable) config.services.calibre-web.servers;
in
{
  options.services.calibre-web.servers = mkOption {
    type = with types; attrsOf (submodule { options = options.services.calibre-web; });
  };

  config = mkIf (enabledServers != { }) {
    systemd.services = mapAttrs'
      (name: cfg:
        let calibre-web = "calibre-web" + optionalString (name != "") ("-" + name); in nameValuePair calibre-web
          (
            let
              appDb = "/var/lib/${cfg.dataDir}/app.db";
              gdriveDb = "/var/lib/${cfg.dataDir}/gdrive.db";
              calibreWebCmd = "${pkgs.calibre-web}/bin/calibre-web -p ${appDb} -g ${gdriveDb}";

              settings = concatStringsSep ", " (
                [
                  "config_port = ${toString cfg.listen.port}"
                  "config_uploading = ${if cfg.options.enableBookUploading then "1" else "0"}"
                  "config_allow_reverse_proxy_header_login = ${if cfg.options.reverseProxyAuth.enable then "1" else "0"}"
                  "config_reverse_proxy_login_header_name = '${cfg.options.reverseProxyAuth.header}'"
                ]
                ++ optional (cfg.options.calibreLibrary != null) "config_calibre_dir = '${cfg.options.calibreLibrary}'"
                ++ optional cfg.options.enableBookConversion "config_converterpath = '${pkgs.calibre}/bin/ebook-convert'"
              );
            in
            {
              description = "Web app for browsing, reading and downloading eBooks stored in a Calibre database";
              after = [ "network.target" ];
              wantedBy = [ "multi-user.target" ];

              serviceConfig = {
                Type = "simple";
                User = cfg.user;
                Group = cfg.group;

                StateDirectory = cfg.dataDir;
                ExecStartPre = pkgs.writeShellScript "${calibre-web}-pre-start" (
                  ''
                    __RUN_MIGRATIONS_AND_EXIT=1 ${calibreWebCmd}

                    ${pkgs.sqlite}/bin/sqlite3 ${appDb} "update settings set ${settings}"
                  '' + optionalString (cfg.options.calibreLibrary != null) ''
                    test -f "${cfg.options.calibreLibrary}/metadata.db" || { echo "Invalid Calibre library"; exit 1; }
                  ''
                );

                ExecStart = "${calibreWebCmd} -i ${cfg.listen.ip}";
                Restart = "on-failure";
              };
            }
          ))
      config.services.calibre-web.servers;
  };
  meta.maintainers = with lib.maintainers;  [ pborzenkov ];
}
