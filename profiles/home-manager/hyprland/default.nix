{
  config,
  lib,
  pkgs,
  ...
}:

let
  ocrScript =
    let
      inherit (pkgs)
        grim
        libnotify
        slurp
        tesseract5
        wl-clipboard
        ;
      _ = lib.getExe;
    in
    pkgs.writeShellScriptBin "wl-ocr" ''
      ${_ grim} -g "$(${_ slurp})" -t ppm - | ${_ tesseract5} - - | ${wl-clipboard}/bin/wl-copy
      ${_ libnotify} "$(${wl-clipboard}/bin/wl-paste)"
    '';
in

lib.mkIf config.wayland.windowManager.hyprland.enable {
  wayland.windowManager.hyprland.extraConfig = import ./config.nix { inherit pkgs; };

  programs = {
    fuzzel.enable = true;
    kitty.enable = true;
    waybar.enable = true;
    wlogout.enable = true;
  };

  services.gammastep = {
    enable = true;
    provider = "geoclue2";
  };

  home.packages =
    with pkgs;
    [
      clipman
      grim
      ocrScript
      pngquant
      python3.pkgs.requests
      slurp
      swayidle
      tesseract5
      wf-recorder
      wl-clipboard
      xorg.xprop
    ]
    ++ lib.optional (pkgs.system == "x86_64-linux") grimblast;
}
