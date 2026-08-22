{ config, lib, ... }:

with lib;

{
  options.accounts.email.accounts = mkOption {
    type = types.attrsOf (
      types.submodule (
        { name, ... }:
        {
          config = mkDefault {
            address = name;
            realName = "Camille Mondon";
            thunderbird = {
              enable = true;
              profiles = [ "camille" ];
            };
          };
        }
      )
    );
  };

  config = lib.mkIf config.programs.thunderbird.enable {
    programs.thunderbird.profiles."camille" = {
      isDefault = true;
      settings = {
        "intl.locale.requested" = "fr,en-US";
        "mail.identity.id3.organization" = "TSE-R";
        "mail.identity.id3.sig_on_fwd" = true;
      };
    };
  };
}
