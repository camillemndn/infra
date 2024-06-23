{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.profiles.browser;
in
with lib;

{
  options.profiles.browser.enable = mkEnableOption "Firefox";

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      languagePacks = [ "fr" ];
      nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
      preferences = {
        "browser.fixup.domainsuffixwhitelist.kms" = true;
        "browser.fixup.domainsuffixwhitelist.luj" = true;
        "browser.fixup.domainsuffixwhitelist.saumon" = true;
      };
      preferencesStatus = "default";
      wrapperConfig.firefox = {
        alsaSupport = true;
        ffmpegSupport = true;
        jackSupport = true;
        pipewireSupport = true;
      };
    };
  };
}
