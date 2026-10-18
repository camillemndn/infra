{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.forgejo;
  domain = "git.mndn.fr";
  port = 3300;
  runner = config.networking.hostName;
  runnerTokenFile = "${cfg.stateDir}/runner-token";
in

{
  # Admin CLI against the live instance, e.g. `forgejo admin user list`.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "forgejo" ''
      cd ${cfg.stateDir}
      exec /run/wrappers/bin/sudo -u ${cfg.user} ${lib.getExe cfg.package} --work-path ${cfg.stateDir} "$@"
    '')
  ];

  services = {
    forgejo = {
      enable = true;
      database.type = "postgres";
      lfs.enable = true;

      settings = {
        server = {
          DOMAIN = domain;
          ROOT_URL = "https://${domain}/";
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = port;
        };

        actions.ENABLED = true;
        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
      };
    };

    gitea-actions-runner = {
      package = pkgs.forgejo-runner;

      instances.${runner} = {
        enable = true;
        name = runner;
        url = cfg.settings.server.ROOT_URL;
        tokenFile = runnerTokenFile;
        # Jobs run on zeppelin itself, building through its nix-daemon.
        labels = [ "native:host" ];
        # One job per check: a host evaluation alone takes up to 3.5 GB.
        settings.runner.capacity = 3;

        hostPackages = with pkgs; [
          attic-client
          bash
          coreutils
          curl
          gawk
          gitMinimal
          gnused
          jq
          nix
          nix-eval-jobs
          nix-fast-build
          nodejs
          # ssh-keygen signs the update bot's commits.
          openssh
          wget
        ];
      };
    };

    nginx.virtualHosts.${domain} = {
      inherit port;

      extraConfig = ''
        client_max_body_size 512M;
      '';
    };
  };

  systemd.services = {
    # Forgejo hands out the runner's registration token, so no secret has to be kept.
    forgejo-runner-token = {
      description = "Forgejo Actions runner registration token";
      after = [ "forgejo.service" ];
      requires = [ "forgejo.service" ];

      environment = {
        inherit (config.systemd.services.forgejo.environment)
          FORGEJO_CUSTOM
          FORGEJO_WORK_DIR
          HOME
          USER
          ;
      };

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = cfg.user;
        Group = cfg.group;
        UMask = "0077";
        # The server may still be starting when the token is asked for.
        Restart = "on-failure";
        RestartSec = 5;
      };

      script = ''
        if [ ! -s ${runnerTokenFile} ]; then
          token=$(${lib.getExe cfg.package} actions generate-runner-token)
          echo "TOKEN=$token" > ${runnerTokenFile}
        fi
      '';
    };

    "gitea-runner-${runner}" = {
      after = [ "forgejo-runner-token.service" ];
      requires = [ "forgejo-runner-token.service" ];
    };
  };
}
