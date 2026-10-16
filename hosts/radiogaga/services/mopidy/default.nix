{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf config.services.mopidy.enable (
  let
    # Upstream mopidy-subidy implements no cover art (no get_images, never reads
    # the coverArt id), so Iris shows no thumbnails. This patch adds get_images,
    # returning a Navidrome getCoverArt URL built with subidy's own auth.
    mopidy-subidy = pkgs.mopidy-subidy.overridePythonAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./cover-art.patch ];
    });
  in
  {
    services.mopidy = {
      extensionPackages = [
        pkgs.mopidy-mpd # MPD server on :6600 (M.A.L.P. and other Android clients)
        pkgs.mopidy-iris # Web UI on :6680/iris (browse/queue/volume from any browser)
        mopidy-subidy # Subsonic backend -> Navidrome (patched for cover art)
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

      # Subsonic username AND password come from an agenix secret decrypted to
      # /run/agenix, owned by mopidy — outside the data dir, so Iris (which can
      # read the data dir) cannot reach it. Layered last, it merges into the
      # [subidy] section. mopidy-subidy also declares `password` as a Secret, so
      # Mopidy masks it in the config view Iris renders.
      extraConfigFiles = [ config.age.secrets.mopidy-subidy.path ];
    };

    # Under this host's system-wide PipeWire, audio clients must be in the
    # "pipewire" group to reach the socket (same as the librespot service here).
    users.users.mopidy.extraGroups = [ "pipewire" ];

    age.secrets.mopidy-subidy = {
      file = ./subidy.age;
      owner = "mopidy";
    };
  }
)
