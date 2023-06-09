{
  genesis = {
    hardware = "asus-laptop";
    users = [ "camille" ];
  };

  offspring = {
    system = "aarch64-linux";
    hardware = "oracle-vm";
    users = [ ];
    ipv4.public = "141.145.197.42";
    ipv6 = { };
    subdomains = [ "offspring.mondon.xyz" ];
  };

  radiogaga = {
    system = "aarch64-linux";
    hardware = "raspberrypi-3b";
    users = [ ];
    tld = "kms";
    ipv4 = {
      public = "129.199.158.3";
      vpn = "100.100.45.19";
    };
    ipv6 = { };
  };

  zeppelin = {
    hardware = "proxmox-vm";
    users = [ ];
    tld = "kms";
    ipv4 = {
      local = "192.168.0.137";
      public = "78.194.168.230";
      vpn = "100.100.45.7";
    };
    ipv6 = {
      public = "2a01:e34:ec2a:8e60:c4f0:fbff:fe8c:d6da";
      vpn = "fd7a:115c:a1e0::7";
    };
  };
}
