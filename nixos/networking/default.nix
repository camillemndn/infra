{ lib, ... }:

{
  options.networking.addresses = lib.mkOption {
    type = lib.types.attrsOf lib.types.anything;
    default = { };
  };
}
