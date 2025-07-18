{
  description = "Denio's NixOS + Home Manager Flake with Hyprland and custom themes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        home-manager-lib = home-manager.lib;
      in {
        nixosConfigurations = {
          denio = pkgs.lib.nixosSystem {
            system = system;
            modules = [
              ./hosts/denio.nix
              home-manager-lib.nixosModules.home-manager
              {
                users.users.denio = {
                  isNormalUser = true;
                  home = "/home/denio";
                  extraGroups = [ "wheel" "docker" ];
                  shell = pkgs.zsh;
                };
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
              }
            ];
          };

        homeConfigurations = {
          denio = home-manager-lib.homeManagerConfiguration {
            system = system;
            pkgs = pkgs;
            modules = [ ./home.nix ];
            username = "denio";
            homeDirectory = "/home/denio";
          };
        };
      });
}
