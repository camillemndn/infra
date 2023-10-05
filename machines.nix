let tld = "kms"; in {
  genesis = {
    hardware = "asus/gv301qe";
    deployment.allowLocalDeployment = true;
  };

  jagger = {
    hardware = "asus/z170progaming";
    deployment.allowLocalDeployment = true;
  };

  nickelback = rec {
    hardware = "intel/nuc5i5ryh";
    users = [ "camille" "manu" ];
    tld = "mondon.xyz";
    ipv4.public = "82.64.106.43";
    ipv6.public = "2a01:e0a:b3b:c0f0:baae:edff:fe74:5a4d";
    deployment = {
      targetHost = ipv6.public;
    };
  };

  offspring = rec {
    system = "aarch64-linux";
    hardware = "virtual/oracle";
    tld = "mondon.xyz";
    ipv4.public = "141.145.197.42";
    ipv6.public = "2603:c027:c002:702:a0c:c8e:cc5e:c723";
    deployment = {
      tags = [ "available" ];
      targetHost = ipv4.public;
      buildOnTarget = true;
    };
  };

  pinkfloyd = {
    system = "aarch64-linux";
    hardware = "pine64/pinephone";
    deployment.targetHost = null;
  };

  radiogaga = rec {
    system = "aarch64-linux";
    hardware = "raspberrypi/3b";
    inherit tld;
    ipv4 = { public = "129.199.158.3"; vpn = "100.100.45.19"; };
    ipv6 = { vpn = "fd7a:115c:a1e0::13"; };
    deployment = {
      targetHost = ipv6.vpn;
    };
  };

  rush = rec {
    system = "aarch64-linux";
    hardware = "raspberrypi/3b";
    inherit tld;
    ipv4 = { public = "82.66.152.179"; vpn = ""; };
    ipv6 = { public = "2a01:e0a:215:d1f0::1"; vpn = ""; };
    deployment = {
      targetHost = ipv6.public;
    };
  };

  zeppelin = rec {
    hardware = "virtual/proxmox";
    inherit tld;
    ipv4 = { local = "192.168.0.137"; public = "78.194.168.230"; vpn = "100.100.45.7"; };
    ipv6 = { public = "2a01:e34:ec2a:8e60:c4f0:fbff:fe8c:d6da"; vpn = "fd7a:115c:a1e0::7"; };
    mailServers = {
      "braithwaite.fr" = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC1s2oN616eFoc+SvHNSAAbImNdNRivTdjK5odLMsq6CIisUkCW1vGAB8XrfmqTCBQRStW+L5K/kgVGMIjBmkN0L7cJkfJUMYvgxWFCvWo2XEsPAh7LhbYuwpyhjVR7nZ/TU52YHz5ekWk8KBuaWCqdbNm0++DqpjfJKDLN7bbaBwIDAQAB";
      "mondon.me" = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJAjB8aUkCIYI541ZeR8uv/BCiy/0TSNqS3C9UXOOVPjTd56haSq+b5m3uto3LvNYXj/xQ33EXwqP+/PVKVDjy4llxdppjoI8qYSktQYbCPVAUfHbMvUlfxcWIVfb2SB2VeOYT1IZ9maZbroxhwzQp4YIGNfMMgMxxvu1y5lwb6wIDAQAB";
      "saumon.network" = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC1MucZU5IoUJvZlDc7L/5E/ZPvEOkwweYk01/w4hsSO9rgb8WC3iQ2I01hsoBYJHt3aJ1+FDfPy/+HcyE3g888P6BQRiJbWD+Kmo58/9wE9c5LQGunWgfLNzbOUWwLhdU1fZE/ts4rRaYkYOZBX5278vnwPzlGX1jr0p+EvsdtBQIDAQAB";
    };
    deployment = {
      tags = [ "available" ];
      targetHost = ipv4.vpn;
      buildOnTarget = true;
    };
  };

}
