{
	description = "System flake";
	inputs = {
		# Official NixOS package source, using nixos-unstable branch here
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

		# home-manager, used for managing user configuration
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# Nix user repositories
		nur.url = "github:nix-community/NUR";

		# WSL
		nixos-wsl = {
			url = "github:nix-community/NixOS-WSL";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = inputs@{ nixpkgs, home-manager, nur, nixos-wsl, ... }: {
		nixosConfigurations = 
		let 
			home = import ./home;
			wm = import ./home/wm;
			home_wm = nixpkgs.lib.mkMerge[home wm];
		in
		{
			"nixos" = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				specialArgs = {
					wm = true;
				};
				modules = [
					./machines/l380
					home-manager.nixosModules.home-manager
					{
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.users.giom = home_wm;
						nixpkgs.overlays = [
							nur.overlay
						];
					}
				];
			};
			
			"wsl" = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				specialArgs = {
					inherit nixos-wsl;
				};
				modules = [
					./machines/wsl
					home-manager.nixosModules.home-manager
					{
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.users.giom = home;
					}
				];
			};	
		};
	};
}