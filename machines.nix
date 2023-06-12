let tld = "kms"; in {
  genesis.hardware = "asus/gv301qe";

  nickelback = {
    hardware = "intel/nuc5i5ryh";
    users = [ "camille" "manu" ];
    tld = "mondon.xyz";
    ipv4.public = "82.64.106.43";
    ipv6.public = "2a01:e0a:b3b:c0f0:baae:edff:fe74:5a4d";
  };

  offspring = {
    system = "aarch64-linux";
    hardware = "virtual/oracle";
    tld = "mondon.xyz";
    ipv4.public = "141.145.197.42";
    ipv6.public = "2603:c027:c002:702:a0c:c8e:cc5e:c723";
  };

  radiogaga = {
    system = "aarch64-linux";
    hardware = "raspberrypi/3b";
    inherit tld;
    ipv4 = { public = "129.199.158.3"; vpn = "100.100.45.19"; };
    ipv6 = { vpn = "fd7a:115c:a1e0::13"; };
    remoteBuild = false;
  };

  rush = {
    system = "aarch64-linux";
    hardware = "raspberrypi/3b";
    inherit tld;
    ipv4 = { public = "82.66.152.179"; vpn = ""; };
    ipv6 = { public = "2a01:e0a:215:d1f0::1"; vpn = ""; };
  };

  zeppelin = {
    hardware = "virtual/proxmox";
    inherit tld;
    ipv4 = { local = "192.168.0.137"; public = "78.194.168.230"; vpn = "100.100.45.7"; };
    ipv6 = { public = "2a01:e34:ec2a:8e60:c4f0:fbff:fe8c:d6da"; vpn = "fd7a:115c:a1e0::7"; };
  };
}
