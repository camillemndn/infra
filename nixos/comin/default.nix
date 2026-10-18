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

    remotes = [
      (remote "forgejo" "https://git.mndn.fr/camille/infra.git")
      (remote "github" "https://github.com/camillemndn/infra.git")
    ];

    # Only commits signed by camille or the update bot are deployed.
    sshAllowedSignersPath = "/etc/ssh/allowed_signers";
    desktop.enable = desktop;
  };
}
