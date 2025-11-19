inputs: lib:
with lib;
let
  modules = [
    {
      options.machines = mkOption {
        description = "My machines";
        type =
          with types;
          attrsOf (
            submodule (
              { name, ... }:
              {
                freeformType = attrs;
                options = {
                  hostname = mkOption {
                    description = "The machine's hostname";
                    type = str;
                    default = name;
                    readOnly = true;
                  };
                  nixpkgs_version = mkOption {
                    description = "Nixpkgs version to use";
                    type = path;
                    default = inputs.nixpkgs;
                  };
                  hm_version = mkOption {
                    description = "Nixpkgs version to use";
                    type = path;
                    default = inputs.home-manager;
                  };
                  system = mkOption {
                    description = "Architecture of the system";
                    type = str;
                    default = "x86_64-linux";
                  };
                  tld = mkOption {
                    description = "The machine's hostname";
                    type = str;
                    default = "kms";
                  };
                };
              }
            )
          );
        default = { };
      };

      config = {
        _module.freeformType = with types; attrs;

        machines = {
          flamenca = { };

          genesis = { };

          greenday.ipv4.public = "82.66.152.179";

          nickelback = {
            ipv4 = {
              public = "82.64.106.43";
              vpn = "100.100.45.27";
            };
            ipv6 = {
              public = "2a01:e0a:b3b:c0f0:baae:edff:fe74:5a4d";
              vpn = "fd7a:115c:a1e0::1b";
            };
          };

          offspring = {
            system = "aarch64-linux";
            tld = "mondon.xyz";
            ipv4.public = "141.145.197.42";
            ipv6.public = "2603:c027:c002:702:a0c:c8e:cc5e:c723";
          };

          pinkfloyd = {
            ipv4.vpn = "100.100.45.3";
            ipv6.vpn = "fd7a:115c:a1e0::3";
          };

          radiogaga = {
            system = "aarch64-linux";
            ipv4.local = "192.168.1.50";
          };

          thelonious = {
            ipv4.vpn = "100.100.45.25";
            ipv6.vpn = "fd7a:115c:a1e0::19";
          };

          zeppelin = {
            ipv4 = {
              local = "192.168.0.137";
              public = "82.67.34.230";
              vpn = "100.100.45.7";
            };
            ipv6 = {
              public = "2a01:e0a:de4:a0e1:c4f0:fbff:fe8c:d6da";
              vpn = "fd7a:115c:a1e0::7";
            };
          };
        };
      };
    }
  ];
in
(evalModules { inherit modules; }).config
