{
  config,
  inputs,
  pkgs,
  ...
}:

let
  # A desktop takes an update at its next boot rather than under its user's session.
  desktop = config.services.graphical-desktop.enable;

  remote = name: url: {
    inherit name url;
    branches.main.operation = if desktop then "boot" else "switch";
  };
in

{
  services.comin = {
    enable = true;
    package = pkgs.callPackage "${inputs.comin}/nix/package.nix" { };
    # Impure evaluation, so inputs.nix patches the sources for this machine's own
    # system; a flake has no builtins.currentSystem. comin reads `toplevel` and
    # `config` under systemAttr, which system.build provides below.
    repositoryType = "nix";
    systemAttr = "nixosConfigurations.${config.networking.hostName}.config.system.build";

    remotes = [
      (remote "forgejo" "https://git.mndn.fr/camille/infra.git")
      (remote "github" "https://github.com/camillemndn/infra.git")
    ];

    # Only commits signed by camille or the update bot are deployed.
    sshAllowedSignersPath = "/etc/ssh/allowed_signers";
    desktop.enable = desktop;
  };

  # The outer `config` is the submodule's definition section, the inner one the attribute.
  system.build.config.config = config;
}
