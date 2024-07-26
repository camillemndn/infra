let
  camille = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINg9kUL5kFcPOWmGy/7kJZMlG2+Ls79XiWgvO8p+OQ3f";
  admins = [ camille ];
  radiogaga = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOOEMuVU61nnhMux78nRO0PD7nalwLGbDfdWYSCawRFC";
  zeppelin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDNKOAMN3AxfW6HKrom5s6D4Yy9WYEAK2FuOQYWLuFm3";
in
{
  "profiles/buildbot-nix/buildbot-nix-worker-password.age".publicKeys = admins ++ [ zeppelin ];
  "profiles/buildbot-nix/buildbot-nix-workers.age".publicKeys = admins ++ [ zeppelin ];
  "profiles/buildbot-nix/github-app-secret.age".publicKeys = admins ++ [ zeppelin ];
  "profiles/buildbot-nix/github-oauth-secret.age".publicKeys = admins ++ [ zeppelin ];
  "profiles/buildbot-nix/github-webhook-secret.age".publicKeys = admins ++ [ zeppelin ];
  "profiles/mailserver/braithwaite.fr-emma.age".publicKeys = admins ++ [ zeppelin ];
  "profiles/mailserver/mondon.me-camille.age".publicKeys = admins ++ [ zeppelin ];
  "profiles/mailserver/saumon.network-verso.age".publicKeys = admins ++ [ zeppelin ];
  "profiles/nextcloud/adminpass.age".publicKeys = admins ++ [ zeppelin ];
  "profiles/photoprism/password.age".publicKeys = admins ++ [ zeppelin ];
  "profiles/plausible/admin-password.age".publicKeys = admins ++ [ zeppelin ];
  "profiles/plausible/secret-key-base.age".publicKeys = admins ++ [ zeppelin ];
  "profiles/spotifyd/spotify-password.age".publicKeys = admins ++ [ radiogaga ];
  "profiles/spotifyd/spotify-username.age".publicKeys = admins ++ [ radiogaga ];
  "profiles/yarr/auth.age".publicKeys = admins ++ [ zeppelin ];
}
