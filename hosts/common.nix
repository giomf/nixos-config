{ config, pkgs, ... }:

{
	nix.settings.experimental-features = [ "nix-command" "flakes" ];
  	time.timeZone = "Europe/Berlin";
	console = {
		keyMap = "de";
		packages = with pkgs; [ terminus_font ];
		font = "ter-u28n";
	};

  	nixpkgs.config.allowUnfree = true;
	virtualisation.docker.enable = true;
  	programs.fish.enable = true;

  	security = {
    	polkit.enable = true;
	  	sudo.wheelNeedsPassword = false;
  	};

  	# User
	users.users.giom = {
		isNormalUser = true;
		shell = pkgs.fish;
		extraGroups = [
			"wheel"
			"docker"
		];
	};
}

