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
  ) (lib.attrsets.filterAttrs (n: _v: lib.strings.hasSuffix "_FILE" n) cfg.settings);

  env-nonfile-values = lib.attrsets.filterAttrs (
    n: _v: !lib.strings.hasSuffix "_FILE" n
  ) cfg.settings;

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

{
  age.secrets.firefly-iii-app-key = {
    file = ./app-key.age;
    owner = cfg.user;
  };

  environment.systemPackages = [ firefly-iii-manage ];

  services = {
    firefly-iii = {
      enable = true;
      enableNginx = true;

      settings = {
        APP_KEY_FILE = config.age.secrets.firefly-iii-app-key.path;
        DB_CONNECTION = "pgsql";
      };

      virtualHost = "finances.kms";
    };

    firefly-iii-data-importer = {
      enable = true;
      enableNginx = true;
      virtualHost = "import.finances.kms";
    };

    nginx.virtualHosts."finances.kms".locations."~ \\.php$".extraConfig = lib.mkAfter ''
      fastcgi_read_timeout 3600;
    '';

    phpfpm.pools = {
      firefly-iii-data-importer.phpOptions = ''
        log_errors = on
        max_execution_time = 3600
      '';

      firefly-iii.phpOptions = ''
        log_errors = on
        max_execution_time = 3600
        memory_limit = 4G
      '';
    };

    postgresql = {
      ensureDatabases = [ "firefly-iii" ];

      ensureUsers = [
        {
          ensureDBOwnership = true;
          name = "firefly-iii";
        }
      ];
    };
  };
}
