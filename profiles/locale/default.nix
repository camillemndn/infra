{
  lib,
  ...
}:

{
  console.keyMap = "fr";

  i18n = {
    defaultLocale = "fr_FR.UTF-8";
    extraLocaleSettings = {
      LANG = "fr_FR.UTF-8";
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_ALL = "fr_FR.UTF-8";
      LC_CTYPE = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MESSAGES = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };
  };

  programs.firefox.languagePacks = [ "fr" ];

  services = {
    nextcloud.settings.default_phone_region = "FR";
    xserver.xkb.layout = "fr";
  };

  time.timeZone = lib.mkOverride 500 "Europe/Paris";
}
