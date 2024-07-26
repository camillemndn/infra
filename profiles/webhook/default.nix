{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.webhook.enable {
  services.webhook.hooks = {
    redeploy-website = {
      command-working-directory = "/srv/sites";
      execute-command = "${pkgs.writeShellScript "redeploy-website" ''
        if [ ! -d "$1-git" ]; then
          ${pkgs.git}/bin/git clone "git@github.com:camillemndn/$1.git"
        fi

        pushd "$1-git"
        ${pkgs.git}/bin/git pull
        ${pkgs.nix}/bin/nix-build -A packages.x86_64-linux.website
        popd

        if [ ! -d "$1" ]; then
          rm -r "$1"
        fi
        cp -r "$1-git/result" "$1"
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

  services.nginx.virtualHosts."webhooks.mondon.xyz".port = config.services.webhook.port;
}
