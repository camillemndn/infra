{ modulesPath, ... }:

{
  imports = [ "${modulesPath}/profiles/minimal.nix" ];

  wsl = {
    enable = true;
    startMenuLaunchers = true;
    nativeSystemd = true;
  };
}
