{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs";
  };

  outputs =
    { self, ... }:
    {
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
