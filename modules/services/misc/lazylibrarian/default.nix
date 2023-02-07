{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.services.lazylibrarian;
in
{
  options = {
    services.lazylibrarian = {
      enable = mkEnableOption "LazyLibrarian";

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for the LazyLibrarian web interface.";
      };

      user = mkOption {
        type = types.str;
        default = "lazylibrarian";
        description = "User under which LazyLibrarian runs.";
      };

      group = mkOption {
        type = types.str;
        default = "lazylibrarian";
        description = "Group under which LazyLibrarian runs.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.lazylibrarian = {
      description = "LazyLibrarian";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [
        python
        python310Packages.urllib3
        python310Packages.charset-normalizer
        python310Packages.certifi
        python310Packages.idna
        python310Packages.levenshtein
      ];
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        Environment = "PYTHONPATH='${python310Packages.urllib3}/lib/python3.10/site-packages ${python310Packages.charset-normalizer}/lib/python3.10/site-packages ${python310Packages.certifi}/lib/python3.10/site-packages ${python310Packages.idna}/lib/python3.10/site-packages ${python310Packages.levenshtein}/lib/python3.10/site-packages'";
        Restart = "on-failure";
      };
      script = ''
        python ${pkgs.lazylibrarian}/LazyLibrarian.py --datadir /var/lib/lazylibrarian
      '';
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 5299 ];
    };

    users.users = mkIf (cfg.user == "lazylibrarian") {
      lazylibrarian = {
        group = cfg.group;
        home = "/var/lib/lazylibrarian";
        createHome = true;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "lazylibrarian") {
      lazylibrarian.gid = config.ids.gids.lazylibrarian;
    };
  };
}
