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

          radiogaga.system = "aarch64-linux";

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
            mailServers = {
              "braithwaite.fr" =
                "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC1s2oN616eFoc+SvHNSAAbImNdNRivTdjK5odLMsq6CIisUkCW1vGAB8XrfmqTCBQRStW+L5K/kgVGMIjBmkN0L7cJkfJUMYvgxWFCvWo2XEsPAh7LhbYuwpyhjVR7nZ/TU52YHz5ekWk8KBuaWCqdbNm0++DqpjfJKDLN7bbaBwIDAQAB";
              "mondon.me" =
                "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJAjB8aUkCIYI541ZeR8uv/BCiy/0TSNqS3C9UXOOVPjTd56haSq+b5m3uto3LvNYXj/xQ33EXwqP+/PVKVDjy4llxdppjoI8qYSktQYbCPVAUfHbMvUlfxcWIVfb2SB2VeOYT1IZ9maZbroxhwzQp4YIGNfMMgMxxvu1y5lwb6wIDAQAB";
              "saumon.network" =
                "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC1MucZU5IoUJvZlDc7L/5E/ZPvEOkwweYk01/w4hsSO9rgb8WC3iQ2I01hsoBYJHt3aJ1+FDfPy/+HcyE3g888P6BQRiJbWD+Kmo58/9wE9c5LQGunWgfLNzbOUWwLhdU1fZE/ts4rRaYkYOZBX5278vnwPzlGX1jr0p+EvsdtBQIDAQAB";
            };
          };
        };
      };
    }
  ];
in
(evalModules { inherit modules; }).config
