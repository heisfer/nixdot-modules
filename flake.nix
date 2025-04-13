{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs";
  };

  outputs =
    { self, ... }@inputs:
    let
      customLib = inputs.nixpkgs.lib.extend (final: prev: import ./lib/default.nix { lib = prev; });
    in
    {

      lib = customLib;

      nixosModules = {
        default = import ./nixos/default.nix;
        hjem = import ./hjem/default.nix;
      };
      homeManagerModules = {
        default = import ./home;
        vesktop = import ./home/vesktop.nix;
        telegram = import ./home/telegram.nix;
      };
    };
}
