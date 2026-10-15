{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.firefly-iii;

  env-file-values = lib.attrsets.mapAttrs' (
    n: v: lib.attrsets.nameValuePair (lib.strings.removeSuffix "_FILE" n) v
  ) (lib.attrsets.filterAttrs (n: v: lib.strings.hasSuffix "_FILE" n) cfg.settings);

  env-nonfile-values = lib.attrsets.filterAttrs (n: v: !lib.strings.hasSuffix "_FILE" n) cfg.settings;

  firefly-iii-manage = pkgs.writeShellScriptBin "firefly-iii-manage" ''
    set -euo pipefail
    set -a
    ${lib.strings.toShellVars env-nonfile-values}
    ${lib.strings.concatLines (
      lib.attrsets.mapAttrsToList (n: v: "${n}=\"$(< ${v})\"") env-file-values
    )}
    set +a
    cd ${cfg.package}
    exec ${pkgs.util-linux}/bin/runuser -u ${cfg.user} --preserve-environment -- ${cfg.package}/artisan "$@"
  '';
in

lib.mkIf cfg.enable {
  environment.systemPackages = [ firefly-iii-manage ];

  services = {
    firefly-iii = {
      virtualHost = "finances.kms";
      enableNginx = true;
      settings = {
        APP_KEY_FILE = config.age.secrets.firefly-iii-app-key.path;
        DB_CONNECTION = "pgsql";
      };
    };

    firefly-iii-data-importer = {
      enable = true;
      virtualHost = "import.finances.kms";
      enableNginx = true;
    };

    postgresql = {
      ensureUsers = [
        {
          name = "firefly-iii";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "firefly-iii" ];
    };

    nginx.virtualHosts."finances.kms".locations."~ \\.php$".extraConfig = lib.mkAfter ''
      fastcgi_read_timeout 3600;
    '';

    phpfpm.pools = {
      firefly-iii.phpOptions = ''
        log_errors = on
        max_execution_time = 3600
        memory_limit = 4G
      '';

      firefly-iii-data-importer.phpOptions = ''
        log_errors = on
        max_execution_time = 3600
      '';
    };
  };

  age.secrets.firefly-iii-app-key = {
    owner = cfg.user;
    file = ./app-key.age;
  };
}
