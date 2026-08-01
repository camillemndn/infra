{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.mopidy.enable {
  services.mopidy = {
    extensionPackages = [
      pkgs.mopidy-mpd # MPD server on :6600 (M.A.L.P. and other Android clients)
      pkgs.mopidy-iris # Web UI on :6680/iris (browse/queue/volume from any browser)
      pkgs.mopidy-subidy # Subsonic backend -> Navidrome
    ];

    # Non-secret config only (RFC42 `settings`; `configuration` was removed).
    # `settings` is rendered to a world-readable file in the Nix store, so NO
    # credentials go here.
    settings = {
      audio.output = "pulsesink";
      mpd.hostname = "::";
      http.hostname = "::";
      subidy.url = "https://music.mndn.fr";
    };

    # The Subsonic username AND password live in a file placed by hand in the
    # Mopidy dataDir (not managed by Nix, so never in the store). This is a
    # plain string path, so Nix does not read or import it. Layered last, it
    # merges into the [subidy] section. Mopidy fails to start if it is missing.
    extraConfigFiles = [ "/var/lib/mopidy/subidy.conf" ];
  };

  # Under this host's system-wide PipeWire, audio clients must be in the
  # "pipewire" group to reach the socket (same as the librespot service here).
  users.users.mopidy.extraGroups = [ "pipewire" ];
}
