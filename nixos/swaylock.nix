{
  home-manager.sharedModules = [
    (
      {
        config,
        lib,
        pkgs,
        ...
      }:

      lib.mkIf config.programs.swaylock.enable {
        programs.swaylock = {
          package = pkgs.swaylock-effects;
          settings = {
            ignore-empty-password = true;
            #font = "FiraCode Nerd Font Mono";
            clock = true;
            timestr = "%R";
            datestr = "%a %e %B";
            screenshots = true;
            fade-in = "0.2";
            effect-blur = "20x4";
            #effect-greyscale = true;
            effect-scale = "0.3";
            indicator = true;
            indicator-radius = "200";
            indicator-thickness = "20";
            indicator-caps-lock = true;
          };
        };
      }
    )
  ];
}
