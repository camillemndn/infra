{
  config,
  lib,
  pkgs,
  ...
}:

{
  age.secrets.webhook-secret.file = ./secret.age;

  services = {
    nginx.virtualHosts."webhooks.mndn.fr".port = config.services.webhook.port;

    webhook = {
      enable = true;
      group = "users";

      hooksTemplated = {
        redeploy-website =
          let
            redeploy-script = pkgs.writeShellScript "redeploy-website" ''
              export PATH=${
                with pkgs;
                lib.makeBinPath [
                  git
                  openssh
                  nix
                ]
              }

              if [ ! -d "$1" ]; then
                git clone git@github.com:"$1".git --recurse-submodules
              fi

              cd "$2"
              git pull --recurse-submodules
              nix-build -A packages.x86_64-linux.website -o www
            '';
          in
          ''
            {
              "id": "redeploy-website",
              "command-working-directory": "/srv/sites",
              "execute-command": "${redeploy-script}",
              "pass-arguments-to-command": [
                {
                  "source": "payload",
                  "name": "repository.full_name"
                },
                {
                  "source": "payload",
                  "name": "repository.name"
                }
              ],
              "trigger-rule": {
                "and": [
                  {
                    "match":
                    {
                      "type": "payload-hmac-sha1",
                      "secret": "{{ getenv "WEBHOOK_SECRET" | js }}",
                      "parameter":
                      {
                        "source": "header",
                        "name": "X-Hub-Signature"
                      }
                    }
                  }
                ]
              }
            }
          '';
      };

      user = "camille";
    };
  };

  systemd.services.webhook.serviceConfig.EnvironmentFile = config.age.secrets.webhook-secret.path;
}
