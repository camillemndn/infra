{ config, lib, pkgs, self, nixpkgs, ... }:

{
  nix = {
    gc.automatic = true;
    optimise.automatic = true;

    registry = {
      nixpkgs.flake = nixpkgs;
      camille.flake = self;
    };

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "camille" ];

      auto-optimise-store = true;
      builders-use-substitutes = true;

      extra-substituters = [ "https://cache.saumon.network/camille" ];

      extra-trusted-public-keys = [ "camille:r1ElbcicaLHPlvECyy3wS+CUj4KWHaCEV2Kt1LEaYI0=" ];

      nix-path = [ "nixpkgs=${nixpkgs}" "nixos=${nixpkgs}" ];
    };

    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';

    distributedBuilds = true;

    buildMachines = [
      (lib.mkIf (config.networking.hostName != "offspring") {
        hostName = self.machines.offspring.ipv4.public;
        sshUser = "root";
        system = "aarch64-linux";
        maxJobs = 8;
      })
    ];
  };

  systemd.services.attic-watch-store = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.attic}/bin/attic watch-store camille";
      Restart = "on-failure";
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
    };
  };
}
