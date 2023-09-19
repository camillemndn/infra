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
      systemdIntegration = true;
      extraConfig = import ./config.nix;
    };

    services.gammastep = {
      enable = true;
      provider = "geoclue2";
    };

    systemd.user.services.swaybg =
      let
        wallpaper = builtins.fetchurl rec {
          name = "wallpaper-${sha256}.png";
          url = "https://raw.githubusercontent.com/rxyhn/wallpapers/main/catppuccin/cat_leaves.png";
          sha256 = "1894y61nx3p970qzxmqjvslaalbl2skj5sgzvk38xd4qmlmi9s4i";
        };
      in
      {
        Unit = {
          Description = "Wayland wallpaper daemon";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = "${pkgs.swaybg}/bin/swaybg --mode fill --image ${wallpaper}";
          Restart = "on-failure";
        };

        Install.WantedBy = [ "graphical-session.target" ];
      };
  };
}
