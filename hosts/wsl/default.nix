{ config, pkgs, nixos-wsl, ... }:

{
	imports = [
		../common.nix
	];

	system.stateVersion = "23.05";

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

