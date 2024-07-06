{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.programs.firefox.enable {
  programs.firefox = {
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

  environment.systemPackages = [ pkgs.firefoxpwa ];
}
