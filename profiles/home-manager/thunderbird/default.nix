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

    accounts.email.accounts = {
      "camillemondon@online.fr" = {
        userName = "camillemondon";
        primary = true;
        imap = {
          host = "imap.free.fr";
          port = 993;
        };
        smtp = {
          host = "smtp.free.fr";
          port = 465;
        };
      };
      "camille.mondon@ens.fr" = {
        userName = "cmondon02";
        imap = {
          host = "clipper.ens.fr";
          port = 993;
        };
        smtp = {
          host = "clipper.ens.fr";
          port = 465;
        };
      };
      "camille.mondon@tse-fr.eu" = {
        userName = "camille.mondon@tse-fr.eu";
        imap = {
          host = "mail.saumon.network";
          port = 1143;
        };
        smtp = {
          host = "mail.saumon.network";
          port = 1025;
        };
        signature = {
          showSignature = "append";
          text = ''
            <small><p><b>Camille MONDON<br></b>
            Doctorant<br>
            <i>TSE-R | Bureau T.234<br>
            1, Esplanade de l'Université 31000 Toulouse</i></p></small>
          '';
        };
      };
      "contact@varanda.fr" = {
        realName = "Varanda";
        userName = "varanda";
        imap = {
          host = "mail.luj.fr";
          port = 993;
        };
        smtp = {
          host = "mail.luj.fr";
          port = 465;
        };
      };
    };
  };
}
