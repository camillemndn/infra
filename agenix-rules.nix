let
  admins = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINg9kUL5kFcPOWmGy/7kJZMlG2+Ls79XiWgvO8p+OQ3f"
  ];

  hostKeys = {
    offspring = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTQP1XL41AvmwxYaoFSAK6p8X9NPdMg8jppRspeV4cy";
    radiogaga = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOOEMuVU61nnhMux78nRO0PD7nalwLGbDfdWYSCawRFC";
    zeppelin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDNKOAMN3AxfW6HKrom5s6D4Yy9WYEAK2FuOQYWLuFm3";
  };

  filesIn =
    suffix: dir:
    builtins.concatLists (
      builtins.attrValues (
        builtins.mapAttrs (
          name: type:
          if type == "directory" then
            filesIn suffix "${dir}/${name}"
          else if builtins.match ".*\\${suffix}" name != null then
            [ "${dir}/${name}" ]
          else
            [ ]
        ) (builtins.readDir (./. + "/${dir}"))
      )
    );

  # A secret named in a host's config (./name.age) gets its rule before the file exists.
  agesIn =
    dir:
    filesIn ".age" dir
    ++ builtins.concatMap (
      nix:
      map (match: "${dirOf nix}/${builtins.head match}") (
        builtins.filter builtins.isList (
          builtins.split "\\./([A-Za-z0-9._/-]+\\.age)" (builtins.readFile (./. + "/${nix}"))
        )
      )
    ) (filesIn ".nix" dir);
in

builtins.listToAttrs (
  builtins.concatMap (
    host:
    map (path: {
      name = path;
      value.publicKeys = admins ++ [ hostKeys.${host} ];
    }) (agesIn "hosts/${host}")
  ) (builtins.attrNames hostKeys)
)
