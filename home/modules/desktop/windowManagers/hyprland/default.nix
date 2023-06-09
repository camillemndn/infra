{ lib, pkgs, ... }:

let
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

{
  imports = [
    ../../dunst
    ../../waybar
    ../../gtk.nix
    ../../rofi.nix
    ../../swaylock.nix
  ];

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

    sessionVariables = {
      # XDG Specifications
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";

      # QT Variables
      DISABLE_QT5_COMPAT = "0";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = lib.mkForce "qt5ct";
      QT_STYLE_OVERRIDE = lib.mkForce "kvantum";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

      # Toolkit Backend Variables
      SDL_VIDEODRIVER = "wayland";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      CLUTTER_BACKEND = "wayland";
      GDK_BACKEND = "wayland";
      MOZ_ENABLE_WAYLAND = "1";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
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
}
