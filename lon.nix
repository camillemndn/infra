# Generated by lon. Do not modify!
let

  lock = builtins.fromJSON (builtins.readFile ./lon.lock);

  # Override with a path defined in an environment variable. If no variable is
  # set, the original path is used.
  overrideFromEnv =
    name: path:
    let
      replacement = builtins.getEnv "LON_OVERRIDE_${name}";
    in
    if replacement == "" then
      path
    else
    # this turns the string into an actual Nix path (for both absolute and
    # relative paths)
    if builtins.substring 0 1 replacement == "/" then
      /. + replacement
    else
      /. + builtins.getEnv "PWD" + "/${replacement}";

  fetchSource =
    args@{ fetchType, ... }:
    if fetchType == "git" then
      builtins.fetchGit (
        {
          inherit (args) url;
          ref = args.branch;
          rev = args.revision;
          narHash = args.hash;
          inherit (args) submodules;
        }
        // (
          if args ? lastModified then
            {
              inherit (args) lastModified;
              shallow = true;
            }
          else
            { }
        )
      )
    else if fetchType == "tarball" then
      builtins.fetchTarball {
        inherit (args) url;
        sha256 = args.hash;
      }
    else
      builtins.throw "Unsupported source type ${fetchType}";

in
builtins.mapAttrs (name: args: overrideFromEnv name (fetchSource args)) lock.sources
