{ config, pkgs, ... }:

{
	imports = [
		../common.nix
	];

	system.stateVersion = "23.05";

	environment.systemPackages = with pkgs; [
		libraspberrypi
	];
	environment.defaultPackages = with pkgs; [];

	# User
	users.users.giom = {
		openssh.authorizedKeys.keys = [
        	"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPI4hVcnH2C5Rq0Pkgv+rw2h1dAm2QQdyboDfW7kUlw giom@glap"
        ];
	};

	hardware = {
		raspberry-pi."4".apply-overlays-dtmerge.enable = true;
		deviceTree = {
			enable = true;
			filter = "*rpi-4-*.dtb";
		};
  	};

	# Networking
	networking = {
		hostName = "pi";
		networkmanager.enable = true;
	};

	# Allow ssh in
    services.openssh.enable = true;

	sdImage.compressImage = false;
	# Workaround needed for: https://github.com/NixOS/nixpkgs/issues/154163
	nixpkgs.overlays = [
		(final: super: {
			makeModulesClosure = x:
			super.makeModulesClosure (x // { allowMissing = true; });
		})
	];
}
