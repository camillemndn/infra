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
          if [ ! -d "$1" ]; then
            ${pkgs.git}/bin/git clone "git@github.com:camillemndn/$1.git"
          fi

          cd "$1"
          ${pkgs.git}/bin/git pull
          ${pkgs.nix}/bin/nix-build -A packages.x86_64-linux.website

          rm -rf www
          cp -r result www
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
