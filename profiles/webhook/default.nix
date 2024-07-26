{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.webhook.enable {
  services.webhook = {
    user = "camille";
    group = "users";
    hooks = {
      redeploy-website = {
        command-working-directory = "/srv/sites";
        execute-command = "${pkgs.writeShellScript "redeploy-website" ''
          export PATH=${
            with pkgs;
            lib.makeBinPath [
              git
              openssh
              nix
            ]
          }

          if [ ! -d "$1" ]; then
            git clone git@github.com:camillemndn/"$1".git
          fi

          cd "$1"
          git pull
          nix-build -A packages.x86_64-linux.website -o www
        ''}";
        pass-arguments-to-command = [
          {
            source = "payload";
            name = "repository.name";
          }
        ];
        trigger-rule = {
          and = [
            {
              match = {
                type = "payload-hash-sha1";
                secret = "verysafesecret";
                parameter = {
                  source = "header";
                  name = "X-Hub-Signature";
                };
              };
            }
            {
              match = {
                type = "value";
                value = "tag";
                parameter = {
                  "source" = "payload";
                  "name" = "ref_type";
                };
              };
            }
          ];
        };
      };
    };
  };

  services.nginx.virtualHosts."webhooks.mondon.xyz".port = config.services.webhook.port;
}
