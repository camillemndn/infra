{ config, lib, pkgs, ... }:

let
  cfg = config.profiles.hyprland;

  # use OCR and copy to clipboard
  ocrScript =
    let
      inherit (pkgs) grim libnotify slurp tesseract5 wl-clipboard;
      _ = lib.getExe;
    in
    pkgs.writeShellScriptBin "wl-ocr" ''
      ${_ grim} -g "$(${_ slurp})" -t ppm - | ${_ tesseract5} - - | ${wl-clipboard}/bin/wl-copy
      ${_ libnotify} "$(${wl-clipboard}/bin/wl-paste)"
    '';
in
with lib;

{
  options.profiles.hyprland = {
    enable = mkEnableOption "Hyprland window manager";
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        clipman
        grim
        ocrScript
        pngquant
        python39Packages.requests
        slurp
        swayidle
        tesseract5
        wf-recorder
        wl-clipboard
        xorg.xprop
      ] ++ lib.optional (pkgs.system == "x86_64-linux") grimblast;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = import ./config.nix { inherit pkgs; };
    };

    services.gammastep = {
      enable = true;
      provider = "geoclue2";
    };

    systemd.user.services.swaybg = {
      Unit = {
        Description = "Wayland wallpaper daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.swaybg}/bin/swaybg -o * -m fill -i /home/camille/Images/.wallpaper.jpg";
        Restart = "on-failure";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
