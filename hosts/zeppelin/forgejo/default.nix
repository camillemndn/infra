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
        actions.ENABLED = true;

        server = {
          DOMAIN = domain;
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = port;
          ROOT_URL = "https://${domain}/";
        };

        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
      };
    };

    gitea-actions-runner = {
      instances.${runner} = {
        enable = true;

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

        # Jobs run on zeppelin itself, building through its nix-daemon.
        labels = [ "native:host" ];
        name = runner;
        # One job per check: a host evaluation alone takes up to 3.5 GB.
        settings.runner.capacity = 3;
        tokenFile = runnerTokenFile;
        url = cfg.settings.server.ROOT_URL;
      };

      package = pkgs.forgejo-runner;
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
      after = [ "forgejo.service" ];
      description = "Forgejo Actions runner registration token";

      environment = {
        inherit (config.systemd.services.forgejo.environment)
          FORGEJO_CUSTOM
          FORGEJO_WORK_DIR
          HOME
          USER
          ;
      };

      requires = [ "forgejo.service" ];

      script = ''
        if [ ! -s ${runnerTokenFile} ]; then
          token=$(${lib.getExe cfg.package} actions generate-runner-token)
          echo "TOKEN=$token" > ${runnerTokenFile}
        fi
      '';

      serviceConfig = {
        Group = cfg.group;
        RemainAfterExit = true;
        # The server may still be starting when the token is asked for.
        Restart = "on-failure";
        RestartSec = 5;
        Type = "oneshot";
        UMask = "0077";
        User = cfg.user;
      };
    };

    "gitea-runner-${runner}" = {
      after = [ "forgejo-runner-token.service" ];
      requires = [ "forgejo-runner-token.service" ];
      # Jobs run scripts from their checkout, which systemd mounts noexec otherwise.
      serviceConfig.ExecPaths = [ "/var/lib/private/gitea-runner" ];
    };
  };
}
