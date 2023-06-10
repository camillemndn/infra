{ config, lib, ... }:

let
  cfg = config.profiles.ca;
in
with lib;

{
  options.profiles.ca = {
    enable = mkEnableOption "CA";
  };

  config = mkIf cfg.enable {
    services.step-ca = {
      enable = true;
      intermediatePasswordFile = "/root/capw";
      address = "100.100.45.7";
      port = 8444;
      openFirewall = true;

      settings = builtins.fromJSON ''
        {
           "root": "/var/lib/step-ca/.step/certs/root_ca.crt",
           "federatedRoots": null,
           "crt": "/var/lib/step-ca/.step/certs/intermediate_ca.crt",
           "key": "/var/lib/step-ca/.step/secrets/intermediate_ca_key",
           "address": "100.100.45.7:8444",
           "insecureAddress": "",
           "dnsNames": [
              "ca.kms"
           ],
           "ssh": {
              "hostKey": "/var/lib/step-ca/.step/secrets/ssh_host_ca_key",
              "userKey": "/var/lib/step-ca/.step/secrets/ssh_user_ca_key"
           },
           "logger": {
              "format": "text"
           },
           "db": {
              "type": "badgerv2",
              "dataSource": "/var/lib/step-ca/.step/db",
              "badgerFileLoadingMode": ""
           },
           "authority": {
              "provisioners": [
                 {
                    "type": "JWK",
                    "name": "camille@mondon.me",
                    "claims": {
                      "enableSSHCA": true
                    },
                    "key": {
                       "use": "sig",
                       "kty": "EC",
                       "kid": "BF_gF0-K6TiMhHhB5fwLxJUZ41T7decWxijsmccmE4E",
                       "crv": "P-256",
                       "alg": "ES256",
                       "x": "J6EEeVAouKYiOcidiXGNwPLl5-G5DZMPf6C8yKxbIYI",
                       "y": "Ly7makjM9eJTgsSIF4-b5hBGYxRXvzI2k2_93ghZXko"
                    },
                    "encryptedKey": "eyJhbGciOiJQQkVTMi1IUzI1NitBMTI4S1ciLCJjdHkiOiJqd2sranNvbiIsImVuYyI6IkEyNTZHQ00iLCJwMmMiOjEwMDAwMCwicDJzIjoiZW5mRzVxeElldWs2MDB4NXE0YW5YZyJ9.fdN0Ozx4eUCxi6R2yAkiaMM1V5hshkFD4mcnEmBqUikVHWB3x3XDsQ.Qzz-W2rcNI1Ywvze.JvU7QX06EmA3HHSf0RqoWOjley9ueWBpqlpY7cIVCXSIY8VlPncBreJmoHOPFoCJeONx_c72_PJyyDKwhbRZJskPd_uVkql9Eeh3LDdgczLFbYt6vsjOoDGVnJKDVw3HBi-zhaqdw2CnxFUy9eofomv40XOPnGr4tzKiSD1AXT4AyOthP9yL_0emlQ8J6qiAT5EpjewAAP85plGBBR8BnZoAA7eLkSub2cPqJb5oft5HWVl8TeumA6p2u6pdYFM-9DWQipgh87LfvP6079b1_gZmY68NYbc1_Tjp2F5A20kNYZRY_Zw5Ao1ncryKCJ3Rez8RQapouLTGTVvhps4.uvIe-e2aJuJ1K1QfOJMZ5A"
                 },
                 {
                    "type": "ACME",
                    "name": "acme",
                    "claims": {
                       "defaultTLSCertDuration": "1680h"
                    }
                 }
             
              ],
              "template": {},
              "backdate": "1m0s"
           },
           "tls": {
              "cipherSuites": [
                 "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256",
                 "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
              ],
              "minVersion": 1.2,
              "maxVersion": 1.3,
              "renegotiation": false
           }
        }                                                         
      '';
    };
  };

  #services.vpnVirtualHosts.ca.port = 8444;
}
