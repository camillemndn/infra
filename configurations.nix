inputs:

with inputs; with builtins;
let
  baseModules = system: [

    ({ pkgs, ... }:
      {
        # Adds all the modules from this flake
        imports = (import ./profiles) ++ attrValues (import ./modules);

        nixpkgs.overlays = [
          (final: prev: {
            # Adds some packages from other flakes
            php74 = phps.packages.${system}.php74;
            php74Extensions = phps.packages.${system}.php74.extensions;
            unstable = unstable.legacyPackages.${system};
            kernel = import kernel { system = system; config.allowUnfree = true; };
            nix-software-center = nix-software-center.packages.${system}.default;
            spicetify-nix = spicetify-nix.packages.${system}.default;
          } //
          # Adds all the package from this flake
          self.packages."${system}"
          )
        ];
      })

    # Adds some modules from other flakes
    sops-nix.nixosModules.sops
    home-manager.nixosModules.home-manager
    simple-nixos-mailserver.nixosModule
  ];
in

{
  genesis = unstable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = (baseModules "x86_64-linux") ++ [
      (import ./hardware/asus-laptop.nix)
      (import ./configurations/genesis)
      { home-manager.users.camille = import ./home/configurations/genesis inputs; }
      lanzaboote.nixosModules.lanzaboote
      hyprland.nixosModules.default
    ];
  };

  icecube = unstable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = (baseModules "x86_64-linux") ++ [
      (import ./hardware/external-usb.nix)
      (import ./configurations/icecube)
      { home-manager.users.camille = import ./home/configurations/icecube inputs; }
    ];
  };

  offspring = unstable.lib.nixosSystem {
    system = "aarch64-linux";
    modules = (baseModules "aarch64-linux") ++ [
      (import ./hardware/oracle-vm.nix)
      (import ./configurations/offspring)
    ];
  };

  radiogaga = unstable.lib.nixosSystem {
    system = "aarch64-linux";
    modules = (baseModules "aarch64-linux") ++ [
      (import ./hardware/raspberrypi-3b.nix)
      (import ./configurations/radiogaga)
    ];
  };

  radiogagaImage = unstable.lib.nixosSystem {
    system = "aarch64-linux";
    modules = (baseModules "aarch64-linux") ++ [
      "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
      { sdImage.firmwareSize = 512; }
      (import ./hardware/raspberrypi-3b.nix)
      (import ./configurations/radiogaga)
    ];
  };

  rush = unstable.lib.nixosSystem {
    system = "aarch64-linux";
    modules = (baseModules "aarch64-linux") ++ [
      (import ./hardware/raspberrypi-4b.nix)
      (import ./configurations/rush)
    ];
  };

  wutang = unstable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = (baseModules "x86_64-linux") ++ [
      (import ./hardware/wsl.nix)
      (import ./configurations/wutang)
      { home-manager.users.camille = import ./home/configurations/base inputs; }
      nixos-wsl.nixosModules.wsl
    ];
  };

  zeppelin = unstable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = (baseModules "x86_64-linux") ++ [
      (import ./hardware/proxmox-vm.nix)
      (import ./configurations/zeppelin)
      (import ./profiles/users/manu.nix)
      { home-manager.users.camille = import ./home/configurations/base inputs; }
    ];
  };

  pinkfloyd = unstable.lib.nixosSystem {
    system = "aarch64-linux";
    modules = (baseModules "x86_64-linux") ++ [
      (import ./hardware/pinephone.nix)
      (import ./configurations/pinkfloyd)
      { home-manager.users.camille = import ./home/configurations/base inputs; }
      (import "${mobile-nixos}/lib/configuration.nix" { device = "pine64-pinephone"; })
      (import "${mobile-nixos}/examples/phosh/phosh.nix")
    ];
  };
}
