{ config, pkgs, nixos-wsl, ... }:

{
	imports = [
		../common.nix
	];

	system.stateVersion = "23.05";

  	system.activationScripts.bin-bash-hack = {
		text = ''
			[[ ! -f /bin/bash ]] && ln -s /run/current-system/sw/bin/bash /bin/bash
			[[ ! -f /usr/bin/perl ]] && ln -s /run/current-system/sw/bin/perl /usr/bin/perl
		'';
 	 };

  	wsl = {
		enable = true;
		defaultUser = "giom";
		startMenuLaunchers = true;
		wslConf = {
			automount.root = "/mnt";
			network.generateHosts = false;
		};
  	};

	networking.hostName = "wsl";
  	environment.systemPackages = with pkgs; [ nodejs ];
}

