{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.profiles.swaylock;
in
with lib;

{
  options.profiles.swaylock = {
    enable = mkEnableOption "Sway Lock Screen";
  };

  config = mkIf cfg.enable {
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        ignore-empty-password = true;
        font = "FiraCode Nerd Font Mono";
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
        #key-hl-color = "880033";
        #separator-color = "00000000";
        #inside-color = "00000099";
        #inside-clear-color = "ffd20400";
        #inside-caps-lock-color = "009ddc00";
        #inside-ver-color = "d9d8d800";
        #inside-wrong-color = "ee2e2400";
        #ring-color = "231f20D9";
        #ring-clear-color = "231f20D9";
        #ring-caps-lock-color = "231f20D9";
        #ring-ver-color = "231f20D9";
        #ring-wrong-color = "231f20D9";
        #line-color = "00000000";
        #line-clear-color = "ffd204FF";
        #line-caps-lock-color = "009ddcFF";
        #line-ver-color = "d9d8d8FF";
        #line-wrong-color = "ee2e24FF";
        #text-clear-color = "ffd20400";
        #text-ver-color = "d9d8d800";
        #text-wrong-color = "ee2e2400";
        #bs-hl-color = "ee2e24FF";
        #caps-lock-key-hl-color = "ffd204FF";
        #caps-lock-bs-hl-color = "ee2e24FF";
        #disable-caps-lock-text = true;
        #text-caps-lock-color = "009ddc";

        color = "282a36";
        inside-color = "1F202A";
        line-color = "1F202A";
        ring-color = "bd93f9";
        text-color = "f8f8f2";
        layout-bg-color = "1F202A";
        layout-text-color = "f8f8f2";
        inside-clear-color = "6272a4";
        line-clear-color = "1F202A";
        ring-clear-color = "6272a4";
        text-clear-color = "1F202A";
        inside-ver-color = "bd93f9";
        line-ver-color = "1F202A";
        ring-ver-color = "bd93f9";
        text-ver-color = "1F202A";
        inside-wrong-color = "ff5555";
        line-wrong-color = "1F202A";
        ring-wrong-color = "ff5555";
        text-wrong-color = "1F202A";
        bs-hl-color = "ff5555";
        key-hl-color = "50fa7b";
        text-caps-lock-color = "f8f8f2";
      };
    };
  };
}
