{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, ... }:
    {
      nixosModules = {
        swayosd = import ./nixos/swayosd.nix;
      };
      homeManagerModules = {
        default = import ./home/vesktop.nix;
        vesktop = import ./home/vesktop.nix;
      };
    };
}
