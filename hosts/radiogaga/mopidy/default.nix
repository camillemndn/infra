{
  config,
  pkgs,
  ...
}:

let
  # mopidy-subidy has no cover art; the patch adds get_images from Navidrome's getCoverArt.
  mopidy-subidy = pkgs.mopidy-subidy.overridePythonAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./cover-art.patch ];
  });
in
{
  age.secrets.mopidy-subidy = {
    file = ./subidy.age;
    owner = "mopidy";
  };

  services = {
    mopidy = {
      # Streams from zeppelin's Navidrome; controlled from Iris (:6680/iris) or MPD (:6600).
      enable = true;

      extensionPackages = [
        pkgs.mopidy-mpd # MPD server on :6600 (M.A.L.P. and other Android clients)
        pkgs.mopidy-iris # Web UI on :6680/iris (browse/queue/volume from any browser)
        mopidy-subidy # Subsonic backend -> Navidrome (patched for cover art)
      ];

      # Rendered into the store: no credentials here.
      settings = {
        audio.output = "pulsesink";
        mpd.hostname = "::";
        http.hostname = "::";
        subidy.url = "https://music.mndn.fr";
      };

      # Subsonic credentials, outside the data dir Iris can read; merged into [subidy].
      extraConfigFiles = [ config.age.secrets.mopidy-subidy.path ];
    };
  };

  # System-wide PipeWire: audio clients need the pipewire group.
  users.users.mopidy.extraGroups = [ "pipewire" ];
}
