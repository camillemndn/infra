{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.graphical-desktop.enable {
  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = with pkgs; [
      firefoxpwa
      gimp-with-plugins
      inkscape-with-extensions
      (mpv.override { scripts = [ mpvScripts.mpris ]; })
    ];
  };

  home-manager.sharedModules = [
    (
      let
        gtkConfig = {
          gtk-decoration-layout = "icon:minimize,maximize,close";
        };
      in

      {
        gtk = {
          gtk3.extraConfig = gtkConfig;

          gtk4 = {
            theme = null;
            extraConfig = gtkConfig;
          };
        };

        home = {
          keyboard.layout = "fr";
          # GDK_BACKEND stays unset: xdg-desktop-portal-gnome refuses ScreenCast/Screenshot otherwise.
          sessionVariables.QT_QPA_PLATFORM = "wayland";
        };

        programs.kitty.enable = true;

        services.random-background = {
          enable = true;

          imageDirectory =
            (builtins.fetchGit {
              url = "https://github.com/orangci/walls-catppuccin-mocha/";
              rev = "7bfdf10d16ad3a689f9f0cf3a0930da3d1a245a8";
            }).outPath;
        };
      }
    )
  ];

  programs = {
    firefox = {
      enable = lib.mkDefault true;
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

    thunderbird = {
      enable = lib.mkDefault true;

      # The nixpkgs build is English only; French comes from Mozilla's language pack for that release.
      policies = {
        RequestedLocales = "fr";

        ExtensionSettings."langpack-fr@thunderbird.mozilla.org" = {
          installation_mode = "normal_installed";
          install_url = "https://releases.mozilla.org/pub/thunderbird/releases/${config.programs.thunderbird.package.version}/linux-x86_64/xpi/fr.xpi";
        };
      };
    };
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
    };

    printing = {
      enable = lib.mkDefault true;

      drivers = with pkgs; [
        cups-browsed
        cups-filters
        gutenprint
      ];
    };

    xserver.xkb.layout = "fr";
  };
}
