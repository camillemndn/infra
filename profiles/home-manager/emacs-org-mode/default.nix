{
  config,
  lib,
  ...
}:

{
  options.programs.emacs.orgMode.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable Org notebooks with Python in Emacs";
  };

  config = lib.mkIf config.programs.emacs.orgMode.enable {
    # Org is built in; envrc gives each buffer its project's direnv environment.
    programs.emacs.extraPackages = epkgs: with epkgs; [ envrc ];
  };
}
