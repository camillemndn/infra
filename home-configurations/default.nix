{ system ? "x86_64-linux", unstable, home-manager, ... }:

let
  username = "camille";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  pkgs = import unstable {
    inherit system;
    config.allowUnfree = true;
    config.xdg.configHome = configHome;
    # overlays = [ .overlay ];
  };
in
{
  genesis = home-manager.lib.homeManagerConfiguration {
    # inherit pkgs;
    # Specify your home configuration modules here, for example,
    # the path to your home.nix.
    modules = [
      ./genesis
      ../home-modules
    ];
  };
  base = home-manager.lib.homeManagerConfiguration {
    # inherit pkgs;
    # Specify your home configuration modules here, for example,
    # the path to your home.nix.
    modules = [
      ./base
      ../home-modules
    ];
  };
}
