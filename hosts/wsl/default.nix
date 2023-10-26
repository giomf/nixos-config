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



  	virtualisation.docker = {	
		daemon.settings = {
			insecure-registries = [ "dehwllcesnexus1:18080" ];
		};
	};

	networking = {
		hostName = "wsl";
		extraHosts = ''
			# Misc
			10.2.0.145      mstfs.claas.com
			10.1.4.65   		dehwllcesnexus1

			# Jumphost
			10.53.13.172    D2210620
			10.53.13.73     D2346034

			# Windows Client
			10.53.7.250     D2203141

			# Buildnodes
			10.1.4.25   		dehwlleitbld01
			10.1.4.98   		dehwlleitbld02
			10.53.13.130    D2295841
		'';
	};
}

