{
  description = "Happ proxy desktop client (VLESS/VMess/Trojan/Shadowsocks) for NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      happ = pkgs.callPackage ./happ.nix { };
    in
    {
      packages.${system} = {
        default = happ;
        happ = happ;
      };

      apps.${system}.default = {
        type = "app";
        program = "${happ}/bin/happ";
      };

      overlays.default = final: prev: {
        happ = final.callPackage ./happ.nix { };
      };

      nixosModules.default = ./happ-module.nix;

      checks.${system} = {
        happ = happ;
        happ-xwayland = pkgs.callPackage ./happ.nix { forceXwayland = true; };
        happ-software = pkgs.callPackage ./happ.nix { forceSoftwareRendering = true; };
      };
    };
}
