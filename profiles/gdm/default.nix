{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.xserver.displayManager.gdm;
in

{
  options.services.xserver.displayManager.gdm = {
    hidpi.enable = lib.mkEnableOption "High DPI";
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;

      displayManager = {
        gdm.wayland = true;

        setupCommands = ''
          xrandr --setprovideroutputsource modesetting NVIDIA-0
          xrandr --auto
        '';
      };

      xkb.layout = "fr";
    };

    environment = {
      pathsToLink = [ "share/thumbnailers" ];

      systemPackages = with pkgs; [
        libheif
        libheif.out
        nufraw-thumbnailer
      ];
    };

    programs.dconf.profiles.gdm.databases =
      let
        inherit (config.stylix.fonts) sansSerif serif monospace;
        fontSize = toString config.stylix.fonts.sizes.applications;
        documentFontSize = toString (config.stylix.fonts.sizes.applications - 1);
      in
      [
        {
          lockAll = true;
          settings."org/gnome/desktop/interface" = {
            text-scaling-factor = if cfg.hidpi.enable then 1.5 else 1.0;
            scaling-factor = lib.gvariant.mkUint32 (if cfg.hidpi.enable then 2 else 1);
            show-battery-percentage = true;
            font-name = "${sansSerif.name} ${fontSize}";
            document-font-name = "${serif.name}  ${documentFontSize}";
            monospace-font-name = "${monospace.name} ${fontSize}";
          };
        }
      ];
  };
}
