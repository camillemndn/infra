{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.mail;
in
with lib;

{
  options.profiles.mail = {
    enable = mkEnableOption "Mail client with Thunderbird";
  };

  config = mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;
      profiles."camille" = {
        isDefault = true;
        settings = {
          "intl.locale.requested" = "fr,en-US";
          "mail.identity.id3.organization" = "TSE-R";
          "mail.identity.id3.htmlSigText" = ''
            <small><p><b>Camille MONDON<br></b>
            Doctorant<br>
            <i>TSE-R | Bureau T.234<br>
            1, Esplanade de l'Université 31000 Toulouse</i></p></small>
          '';
          "mail.identity.id3.sig_on_fwd" = true;
        };
      };
    };

    accounts.email = {
      accounts."camillemondon@online.fr" = {
        realName = "Camille Mondon";
        address = "camillemondon@online.fr";
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
        thunderbird = {
          enable = true;
          profiles = [ "camille" ];
        };
      };
      accounts."camille.mondon@ens.fr" = {
        realName = "Camille Mondon";
        address = "camille.mondon@ens.fr";
        userName = "cmondon02";
        imap = {
          host = "clipper.ens.fr";
          port = 993;
        };
        smtp = {
          host = "clipper.ens.fr";
          port = 465;
        };
        thunderbird = {
          enable = true;
          profiles = [ "camille" ];
        };
      };
      accounts."camille.mondon@tse-fr.eu" = {
        realName = "Camille Mondon";
        address = "camille.mondon@tse-fr.eu";
        userName = "camille.mondon@tse-fr.eu";
        imap = {
          host = "mail.saumon.network";
          port = 1143;
        };
        smtp = {
          host = "mail.saumon.network";
          port = 1025;
        };
        thunderbird = {
          enable = true;
          profiles = [ "camille" ];
        };
      };
    };
  };
}

