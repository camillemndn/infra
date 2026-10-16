{
  config,
  inputs,
  lib,
  ...
}:

{
  imports = [ "${inputs.home-manager}/nixos" ];
  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "hm-bak";
    users = lib.genAttrs (builtins.attrNames (
      lib.filterAttrs (_: u: u.isNormalUser) config.users.users
    )) (_: { });
  };
}
