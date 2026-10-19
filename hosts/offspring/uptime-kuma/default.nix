{
  config,
  hosts,
  inputs,
  lib,
  nixosConfigurations,
  ...
}:

let

  inherit
    (lib.dnsZones {
      inherit
        config
        hosts
        nixosConfigurations
        ;
    })
    publicMachines
    nginxOf
    ;

  # Status page groups, in order; other monitors show only in the dashboard.
  groups = [
    "Hosts"
    "Services"
    "Websites"
    "DNS"
  ];

  # Per public virtual host: name, group, page and expected text; other attributes
  # go to the monitor. Unlisted hosts are still checked, under their domain.
  vhostMonitors = {
    "analytics.mndn.fr" = {
      keyword = ''"clickhouse":"ok"'';
      name = "📈 Analytics";
      path = "/api/health";
    };

    "auth.mndn.fr" = {
      keyword = "true";
      name = "🔑 Accounts";
      path = "/status";
    };

    "camillemondon.com" = {
      group = "Websites";
      name = "🌐 Camille Mondon";
    };

    "ceciliaflamenca.com" = {
      group = "Websites";
      name = "🌐 Cecilia flamenca";
    };

    # A worker that lost the master lists no connection.
    "ci.mndn.fr" = {
      invertKeyword = true;
      keyword = ''"connected_to": []'';
      name = "🏗 CI";
      path = "/api/v2/workers";
    };

    "cloud.mndn.fr" = {
      keyword = ''"maintenance":false'';
      name = "☁️ Cloud";
      path = "/status.php";
    };

    # Webtrees answers 406 to any User-Agent containing "Uptime".
    "family.mndn.fr" = {
      headers = builtins.toJSON { "User-Agent" = "mndn-status/1.0"; };
      name = "🌳 Genealogy";
    };

    "genealogy.mndn.fr".name = "🌲 Family tree";

    # Answers 424 unless the database and cache answer.
    "git.mndn.fr" = {
      name = "🗃 Git";
      path = "/api/healthz";
    };

    "meals.mndn.fr".name = "🍲 Recipes";

    "media.mndn.fr" = {
      keyword = "Healthy";
      name = "📽 Streaming";
      path = "/health";
    };

    "music.mndn.fr" = {
      name = "🎵 Music";
      path = "/ping";
    };

    "ntfy.mndn.fr" = {
      keyword = ''"healthy":true'';
      name = "📣 Notifications";
      path = "/v1/health";
    };

    "requests.mndn.fr" = {
      name = "🗳 Requests";
      path = "/api/v1/status";
    };

    "sso.mndn.fr".name = "🛂 Sign-in";

    "varanda.fr" = {
      group = "Websites";
      name = "🌐 Varanda";
    };

    "webhooks.mndn.fr" = {
      group = null;
      keyword = "OK";
      name = "🪝 Webhooks";
    };

    "www.natachamondonericpierre.mndn.fr" = {
      group = "Websites";
      name = "🌐 Natacha Mondon & Éric Pierre";
    };

    "yali.es" = {
      group = "Websites";
      name = "🌐 Yali";
    };
  };

  # Nothing to check: uptime/status die with their reporter, code.mndn.fr shows a
  # sign-in page, hidimdaml has no root page, the bridge is checked on IMAP/SMTP.
  unmonitored = [
    "uptime.mndn.fr"
    "status.mndn.fr"
    "code.mndn.fr"
    "hidimdaml.camillemondon.com"
    "bridge.mndn.fr"
  ];

  machineTag = machine: [
    {
      name = "machine";
      value = machine;
    }
  ];

  # Every public virtual host over HTTPS; redirects and wildcards have no page.
  vhostChecks = lib.concatLists (
    lib.mapAttrsToList (
      machine: _:
      let
        nginx = nginxOf machine;

        isRedirect =
          vhost:
          vhost.globalRedirect != null || lib.hasPrefix "30" (toString (vhost.locations."/".return or null));

        isMonitored =
          name: vhost:
          lib.hasSuffixIn nginx.publicDomains name
          && !isRedirect vhost
          && !lib.hasInfix "*" name
          && !lib.elem name unmonitored;

        check =
          domain:
          let
            entry = {
              group = "Services";
              name = domain;
              path = "/";
            }
            // vhostMonitors.${domain} or { };
          in
          {
            inherit (entry) name group;

            probe = {
              expiryNotification = true;
              tags = machineTag machine;
              type = if entry ? keyword then "keyword" else "http";
              url = "https://${domain}${entry.path}";
            }
            // removeAttrs entry [
              "name"
              "group"
              "path"
            ];
          };
      in
      lib.optionals nginx.enable (
        map check (lib.attrNames (lib.filterAttrs isMonitored nginx.virtualHosts))
      )
    ) publicMachines
  );

  # SSH over IPv6: offspring cannot reach its own public IPv4 through its NAT.
  hostChecks = lib.mapAttrsToList (machine: m: {
    group = "Hosts";
    name = machine;

    probe = {
      hostname = m.ipv6.public or m.ipv4.public;
      port = 22;
      tags = machineTag machine;
      type = "port";
    };
  }) publicMachines;

  # Zones are checked through mndn.fr: ns1 is the SaumonNet router, ns2 offspring
  # behind its NAT. A validating resolver answers SERVFAIL on broken signatures.
  dnsCheck = name: server: {
    inherit name;
    group = "DNS";

    probe = {
      dns_resolve_server = server;
      dns_resolve_type = "SOA";
      hostname = "mndn.fr";
      port = 53;
      type = "dns";
    };
  };

  otherChecks = [
    (dnsCheck "📝 ns1" "77.42.114.11")
    (dnsCheck "📝 ns2" config.networking.addresses.ipv4.local)
    (dnsCheck "🔏 DNSSEC" "1.1.1.1")
    {
      group = "Services";
      name = "📬 Mail (IMAP)";

      probe = {
        hostname = "bridge.mndn.fr";
        port = 1143;
        type = "port";
      };
    }
    {
      group = "Services";
      name = "📬 Mail (SMTP)";

      probe = {
        hostname = "bridge.mndn.fr";
        port = 1025;
        type = "port";
      };
    }
    # A status ping is answered by Velocity or lazymc and wakes no server.
    {
      group = "Services";
      name = "⛏ Minecraft";

      probe = {
        game = "minecraft";
        hostname = "v1.mc.mndn.fr";
        port = 25565;
        type = "gamedig";
      };
    }
  ];

  checks = hostChecks ++ vhostChecks ++ otherChecks;
  monitorsIn = group: map (c: c.name) (lib.filter (c: c.group == group) checks);
in

{
  imports = [ "${inputs.stateless-uptime-kuma}/nixos/module.nix" ];
  age.secrets.uptime-kuma-password.file = ./password.age;

  assertions = [
    {
      assertion = lib.allUnique (map (c: c.name) checks);
      message = "Two Uptime Kuma monitors share a name.";
    }
  ];

  nixpkgs.overlays = [
    (final: prev: {
      statelessUptimeKuma =
        (final.callPackage "${inputs.stateless-uptime-kuma}/stateless-uptime-kuma.nix" {
          python3 = prev.python3.override {
            packageOverrides = _: pyPrev: {
              # Fork speaking the Uptime Kuma 2.x API.
              uptime-kuma-api = pyPrev.uptime-kuma-api.overridePythonAttrs {
                src = inputs.uptime-kuma-api;
              };
            };
          };
        }).overridePythonAttrs
          {
            # Upstream's lib.fileset.gitTracked needs a .git directory.
            src = inputs.stateless-uptime-kuma;
          };
    })
  ];

  services = {
    nginx.virtualHosts = {
      "ntfy.mndn.fr" = {
        port = 3002;
        websockets = true;
      };

      "status.mndn.fr" = {
        port = 3001;
        websockets = true;
      };

      "uptime.mndn.fr" = {
        port = 3001;
        websockets = true;
      };
    };

    ntfy-sh = {
      enable = true;

      settings = {
        auth-default-access = "deny-all";
        auth-file = "/var/lib/ntfy-sh/user.db";
        base-url = "https://ntfy.mndn.fr";
        listen-http = "127.0.0.1:3002";
        upstream-base-url = "https://ntfy.sh";
      };
    };

    uptime-kuma.enable = true;
  };

  # Matched by name: same-named manual monitors are taken over, others left alone.
  statelessUptimeKuma = {
    enableService = true;
    host = "http://127.0.0.1:3001";
    passwordFile = config.age.secrets.uptime-kuma-password.path;

    probesConfig = {
      monitors = lib.listToAttrs (map (c: lib.nameValuePair c.name c.probe) checks);

      # status.mndn.fr: names and states only, never addresses.
      status_pages.public = {
        domainNameList = [ "status.mndn.fr" ];

        publicGroupList = lib.filter (g: g.monitorList != [ ]) (
          map (group: {
            monitorList = monitorsIn group;
            name = group;
          }) groups
        );

        showTags = false;
        title = "Public status";
      };
    };

    username = "Camille";
  };

  systemd.services.ntfy-sh.serviceConfig.StateDirectory = "ntfy-sh";
}
