{
  system = "aarch64-linux";
  tld = "mndn.fr";
  ipv4 = {
    # The public address is a NAT address of the cloud provider; the instance
    # only ever sees the one below.
    local = "10.0.0.163";
    public = "158.178.204.106";
  };
  ipv6.public = "2603:c027:c002:702:a0c:c8e:cc5e:c723";
}
