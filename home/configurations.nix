inputs: { ... }:

with inputs;

# let
# username = "camille";
# homeDirectory = "/home/${username}";
# configHome = "${homeDirectory}/.config";

# pkgs = import unstable {
# inherit system;
# config.allowUnfree = true;
# config.xdg.configHome = configHome;
# overlays = [ .overlay ];
# };
# in

{
  "camille@genesis" = home-manager.lib.homeManagerConfiguration {
    # inherit pkgs;
    # Specify your home configuration modules here, for example,
    # the path to your home.nix.
    modules = [
      ./configurations/genesis
      ./modules
      spicetify-nix.homeManagerModule
    ];
  };

  "camille" = home-manager.lib.homeManagerConfiguration {
    # inherit pkgs;
    # Specify your home configuration modules here, for example,
    # the path to your home.nix.
    modules = [
      ./configurations/base
      ./modules
    ];
  };
}
