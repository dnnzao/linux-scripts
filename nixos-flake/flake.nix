{
  description = "Denio's NixOS + Home Manager Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.denio = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ config, pkgs, ... }: {
          # Basic configuration
          networking.hostName = "denio-nixos";
          time.timeZone = "America/Sao_Paulo";
          
          # Bootloader
          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
        })
        ./hosts/denio.nix
        home-manager.nixosModules.home-manager
        ({ config, pkgs, ... }: {
          home-manager.users.denio = import ./home.nix;
          users.users.denio = {
            isNormalUser = true;
            home = "/home/denio";
            extraGroups = [ "wheel" "docker" "audio" "video" "bluetooth" ];
            shell = pkgs.zsh;
          };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        })
      ];
    };
  };
}