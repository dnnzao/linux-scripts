{
  description = "Denio's NixOS + Home Manager Flake with Hyprland and custom themes";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }@inputs: {
    nixosConfigurations.denio = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/denio.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.users.denio = import ./home.nix;
          users.users.denio = {
            isNormalUser = true;
            home = "/home/denio";
            extraGroups = [ "wheel" "docker" "audio" "video" "bluetooth" ];
            shell = nixpkgs.legacyPackages.x86_64-linux.zsh;
          };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
    };
  };
}