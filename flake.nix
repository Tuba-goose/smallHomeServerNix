{
	description = "Home server";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
		sops-nix.url = "github:Mic92/sops-nix";
		sops-nix.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = { self, nixpkgs, sops-nix, ... }: {
		nixosConfigurations.HPnixos = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";

			modules = [
				./configuration.nix
				./dockerStack.nix
			
				sops-nix.nixosModules.sops
				#brings sops into scope for everything else in the config
				#To edit the secrets.yaml files run sops secrets.yaml
			];
		};
	};
}
