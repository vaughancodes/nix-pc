{
  description = "Nix Configs";

  inputs = {
    # NixOS official package source, using unstable 
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: {

    nixosConfigurations = {

      # Setup Daniel's PC
      SDV-NixOS-PC = let
        hostName = "SDV-NixOS-PC";
        specialArgs = {
          inherit hostName;
          };
      in nixpkgs.lib.nixosSystem {
        inherit specialArgs;
        system = "x86_64-linux";

        modules = [
          ./general-config # Import general modules
          ./nvidia-graphics # Import nvidia graphics
          ./${hostName} # Import host specific config
        ];

      };
    };
  };
}
