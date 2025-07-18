{
  description = "Denio's Complete NixOS Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, hyprland, ... }: {
    nixosConfigurations.denio = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/denio.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.denio = import ./home.nix;
            extraSpecialArgs = { inherit inputs; };
          };
        }
        hyprland.nixosModules.default
        {
          # Enable experimental features for flakes
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          
          # Allow unfree packages
          nixpkgs.config.allowUnfree = true;
          
          # Enable networking
          networking.networkmanager.enable = true;
        }
      ];
    };
  };
}