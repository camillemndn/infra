{
  config,
  inputs,
  lib,
  ...
}:

let
  inherit (config.networking) hostName;
  inherit (import ../..) machines nixosConfigurations;

  inherit
    (lib.dnsZones {
      inherit
        config
        hostName
        machines
        nixosConfigurations
        ;
    })
    publicMachines
    nginxOf
    ;

  # The groups of the status page, in order. A monitor outside them is only
  # visible in the dashboard.
  groups = [
    "Hosts"
    "Services"
    "Websites"
    "DNS"
  ];

  # How a public virtual host appears: its name, its group, the page checked
  # and the text that page must contain. Other attributes go to the monitor
  # as they are. A host missing here is still checked, under its domain.
  vhostMonitors = {
    "analytics.mndn.fr" = {
      name = "📈 Analytics";
      path = "/api/health";
      keyword = ''"clickhouse":"ok"'';
    };
    "auth.mndn.fr" = {
      name = "🔑 Accounts";
      path = "/status";
      keyword = "true";
    };
    # A worker that lost the master lists no connection.
    "ci.mndn.fr" = {
      name = "🏗 CI";
      path = "/api/v2/workers";
      keyword = ''"connected_to": []'';
      invertKeyword = true;
    };
    "cloud.mndn.fr" = {
      name = "☁️ Cloud";
      path = "/status.php";
      keyword = ''"maintenance":false'';
    };
    # Webtrees answers 406 to any User-Agent containing "Uptime".
    "family.mndn.fr" = {
      name = "🌳 Genealogy";
      headers = builtins.toJSON { "User-Agent" = "mndn-status/1.0"; };
    };
    "genealogy.mndn.fr".name = "🌲 Family tree";
    "meals.mndn.fr".name = "🍲 Recipes";
    "media.mndn.fr" = {
      name = "📽 Streaming";
      path = "/health";
      keyword = "Healthy";
    };
    "music.mndn.fr" = {
      name = "🎵 Music";
      path = "/ping";
    };
    "ntfy.mndn.fr" = {
      name = "📣 Notifications";
      path = "/v1/health";
      keyword = ''"healthy":true'';
    };
    "requests.mndn.fr" = {
      name = "🗳 Requests";
      path = "/api/v1/status";
    };
    "sso.mndn.fr".name = "🛂 Sign-in";
    "webhooks.mndn.fr" = {
      name = "🪝 Webhooks";
      group = null;
      keyword = "OK";
    };

    "camillemondon.com" = {
      name = "🌐 Camille Mondon";
      group = "Websites";
    };
    "ceciliaflamenca.com" = {
      name = "🌐 Cecilia flamenca";
      group = "Websites";
    };
    "varanda.fr" = {
      name = "🌐 Varanda";
      group = "Websites";
    };
    "www.natachamondonericpierre.mndn.fr" = {
      name = "🌐 Natacha Mondon & Éric Pierre";
      group = "Websites";
    };
    "yali.es" = {
      name = "🌐 Yali";
      group = "Websites";
    };
  };

  # Virtual hosts with nothing of their own to check: Uptime Kuma's pages go
  # down with the machine that would report it, code.mndn.fr answers with the
  # sign-in page, hidimdaml has no page at its root, and the mail bridge is
  # checked on its IMAP and SMTP ports.
  unmonitored = [
    "uptime.mndn.fr"
    "status.mndn.fr"
    "code.mndn.fr"
    "hidimdaml.camillemondon.com"
    "bridge.saumon.network"
  ];

  machineTag = machine: [
    {
      name = "machine";
      value = machine;
    }
  ];

  # Every public virtual host of every publicly reachable machine, checked
  # over HTTPS. Redirects and wildcards have no page of their own.
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
              name = domain;
              group = "Services";
              path = "/";
            }
            // vhostMonitors.${domain} or { };
          in
          {
            inherit (entry) name group;
            probe = {
              type = if entry ? keyword then "keyword" else "http";
              url = "https://${domain}${entry.path}";
              expiryNotification = true;
              tags = machineTag machine;
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

  # SSH on every publicly reachable machine, over IPv6: offspring cannot reach
  # its own public IPv4 through the NAT in front of it.
  hostChecks = lib.mapAttrsToList (machine: m: {
    name = machine;
    group = "Hosts";
    probe = {
      type = "port";
      hostname = m.ipv6.public or m.ipv4.public;
      port = 22;
      tags = machineTag machine;
    };
  }) publicMachines;

  # Every zone is checked through mndn.fr. ns1 is the SaumonNet router and ns2
  # is offspring, asked on the address it binds behind the NAT. A validating
  # resolver answers SERVFAIL once the signatures stop validating.
  dnsCheck = name: server: {
    inherit name;
    group = "DNS";
    probe = {
      type = "dns";
      hostname = "mndn.fr";
      dns_resolve_type = "SOA";
      dns_resolve_server = server;
      port = 53;
    };
  };

  otherChecks = [
    (dnsCheck "📝 ns1" "77.42.114.11")
    (dnsCheck "📝 ns2" machines.offspring.ipv4.local)
    (dnsCheck "🔏 DNSSEC" "1.1.1.1")
    {
      name = "📬 Mail (IMAP)";
      group = "Services";
      probe = {
        type = "port";
        hostname = "bridge.saumon.network";
        port = 1143;
      };
    }
    {
      name = "📬 Mail (SMTP)";
      group = "Services";
      probe = {
        type = "port";
        hostname = "bridge.saumon.network";
        port = 1025;
      };
    }
    # A status ping is answered by Velocity or lazymc and wakes no server.
    {
      name = "⛏ Minecraft";
      group = "Services";
      probe = {
        type = "gamedig";
        game = "minecraft";
        hostname = "v1.mc.mndn.fr";
        port = 25565;
      };
    }
  ];

  checks = hostChecks ++ vhostChecks ++ otherChecks;

  monitorsIn = group: map (c: c.name) (lib.filter (c: c.group == group) checks);
in

{
  config = lib.mkIf config.services.uptime-kuma.enable {
    # Monitors are matched by name: a monitor made by hand under the same name
    # is taken over, and one not declared here is left alone.
    statelessUptimeKuma = {
      enableService = true;
      host = "http://127.0.0.1:3001";
      username = "Camille";
      passwordFile = config.age.secrets.uptime-kuma-password.path;

      probesConfig = {
        monitors = lib.listToAttrs (map (c: lib.nameValuePair c.name c.probe) checks);

        # The page behind status.mndn.fr. It shows names and states only: a
        # monitor's address is never sent to visitors.
        status_pages.public = {
          title = "Public status";
          domainNameList = [ "status.mndn.fr" ];
          showTags = false;
          publicGroupList = lib.filter (g: g.monitorList != [ ]) (
            map (group: {
              name = group;
              monitorList = monitorsIn group;
            }) groups
          );
        };
      };
    };

    assertions = [
      {
        assertion = lib.allUnique (map (c: c.name) checks);
        message = "Two Uptime Kuma monitors share a name.";
      }
    ];

    age.secrets.uptime-kuma-password.file = ./password.age;

    nixpkgs.overlays = [
      (final: prev: {
        statelessUptimeKuma =
          (final.callPackage "${inputs.stateless-uptime-kuma}/stateless-uptime-kuma.nix" {
            python3 = prev.python3.override {
              packageOverrides = _: pyPrev: {
                # The released client speaks the Uptime Kuma 1.x API; this fork
                # sends the fields 2.x requires.
                uptime-kuma-api = pyPrev.uptime-kuma-api.overridePythonAttrs {
                  src = inputs.uptime-kuma-api;
                };
              };
            };
          }).overridePythonAttrs
            {
              # Upstream selects its sources with lib.fileset.gitTracked, which
              # needs a .git directory that a fetched checkout lacks.
              src = inputs.stateless-uptime-kuma;
            };
      })
    ];

    services = {
      ntfy-sh = {
        enable = true;
        settings = {
          base-url = "https://ntfy.mndn.fr";
          upstream-base-url = "https://ntfy.sh";
          auth-file = "/var/lib/ntfy-sh/user.db";
          auth-default-access = "deny-all";
          listen-http = "127.0.0.1:3002";
        };
      };

      nginx.virtualHosts = {
        "uptime.mndn.fr" = {
          port = 3001;
          websockets = true;
        };
        "status.mndn.fr" = {
          port = 3001;
          websockets = true;
        };
        "ntfy.mndn.fr" = {
          port = 3002;
          websockets = true;
        };
      };
    };

    systemd.services.ntfy-sh.serviceConfig.StateDirectory = "ntfy-sh";
  };
}
