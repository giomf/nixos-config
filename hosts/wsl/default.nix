{ config, pkgs, ... }:

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
    defaultUser = "guif";
    startMenuLaunchers = true;
    wslConf = {
      automount.root = "/mnt";
      network.generateHosts = false;
    };
  };

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      insecure-registries = [ "dehwllcesnexus1:18080" ];
    };
  };

	networking = 
   let
      preview_script = (pkgs.writeShellScript "preview_script" (builtins.readFile ./preview_script.sh));
    in
  {
		hostName = "wsl";
		extraHosts = (builtins.readFile ./hosts);
	};
}

