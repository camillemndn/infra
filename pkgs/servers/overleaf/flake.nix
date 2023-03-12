{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  description = "A very basic flake";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.callPackage ./default.nix { };

    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

  };
}
