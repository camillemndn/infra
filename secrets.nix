let
  camille = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINg9kUL5kFcPOWmGy/7kJZMlG2+Ls79XiWgvO8p+OQ3f";
  admins = [ camille ];
  offspring = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTQP1XL41AvmwxYaoFSAK6p8X9NPdMg8jppRspeV4cy";
  radiogaga = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOOEMuVU61nnhMux78nRO0PD7nalwLGbDfdWYSCawRFC";
  zeppelin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDNKOAMN3AxfW6HKrom5s6D4Yy9WYEAK2FuOQYWLuFm3";
in
{
  "machines/zeppelin/services/buildbot-nix/buildbot-nix-worker-password.age".publicKeys = admins ++ [
    zeppelin
  ];
  "machines/zeppelin/services/buildbot-nix/buildbot-nix-workers.age".publicKeys = admins ++ [
    zeppelin
  ];
  "machines/zeppelin/services/buildbot-nix/github-app-secret.age".publicKeys = admins ++ [ zeppelin ];
  "machines/zeppelin/services/buildbot-nix/github-oauth-secret.age".publicKeys = admins ++ [
    zeppelin
  ];
  "machines/zeppelin/services/buildbot-nix/github-webhook-secret.age".publicKeys = admins ++ [
    zeppelin
  ];
  "machines/zeppelin/services/firefly-iii/app-key.age".publicKeys = admins ++ [ zeppelin ];
  "machines/zeppelin/services/oauth2-proxy/oidc-client-secret.age".publicKeys = admins ++ [
    zeppelin
  ];
  "machines/zeppelin/services/kanidm/idm-admin-password.age".publicKeys = admins ++ [ zeppelin ];
  "machines/zeppelin/services/knot/tsig.age".publicKeys = admins ++ [ zeppelin ];
  "machines/offspring/services/nsd/tsig.age".publicKeys = admins ++ [ offspring ];
  "machines/zeppelin/services/oauth2-proxy/cookie-secret.age".publicKeys = admins ++ [ zeppelin ];
  "machines/zeppelin/services/minecraft-server/ops.json.age".publicKeys = admins ++ [ zeppelin ];
  "machines/radiogaga/services/mopidy/subidy.age".publicKeys = admins ++ [ radiogaga ];
  "machines/zeppelin/services/minecraft-server/whitelist.json.age".publicKeys = admins ++ [
    zeppelin
  ];
  "machines/zeppelin/services/nextcloud/adminpass.age".publicKeys = admins ++ [ zeppelin ];
  "machines/zeppelin/services/photoprism/password.age".publicKeys = admins ++ [ zeppelin ];
  "machines/zeppelin/services/plausible/secret-key-base.age".publicKeys = admins ++ [ zeppelin ];
  "machines/zeppelin/services/slskd/env.age".publicKeys = admins ++ [ zeppelin ];
  "machines/offspring/services/uptime-kuma/password.age".publicKeys = admins ++ [ offspring ];
  "machines/zeppelin/services/webhook/secret.age".publicKeys = admins ++ [ zeppelin ];
}
