{ config, pkgs, nixos-wsl, ... }:

{
	imports = [
		../common.nix
	];

	system.stateVersion = "23.05";

  	system.activationScripts.bin-bash-hack = {
		text = ''
			ln -s /run/current-system/sw/bin/bash /bin/bash  
		'';
 	 };

  	wsl = {
		enable = true;
		wslConf.automount.root = "/mnt";
		defaultUser = "giom";
		startMenuLaunchers = true;

		# Enable native Docker support
		# docker-native.enable = true;

		# Enable integration with Docker Desktop (needs to be installed)
		# docker-desktop.enable = true;
  	};

  	networking.hostName = "wsl";
  	environment.systemPackages = with pkgs; [ nodejs ];
}

