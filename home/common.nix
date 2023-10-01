{ config, pkgs, ... }:

{
	# Packages
	home.packages = with pkgs; [
		# Base
		alacritty
		ranger
		pavucontrol
		pulseaudio
		zellij
		eza
		bat
		flameshot
		btop
		unzip

		# Coding
		git
		rustup

		# Office
		libreoffice-qt
		keepassxc
		thunderbird
		
		# Social
		telegram-desktop
		element-desktop
		discord
		spotify
		nextcloud-client
	];

	# Programs
	programs.vim = {
		enable = true;
		defaultEditor = true;
	};

	# Services
	services.ssh-agent.enable = true;
	services.blueman-applet.enable = true;

	## Notification daemon
	services.mako = {
		enable = true;
		defaultTimeout = 7500;
		maxVisible = 3;
	};
}
