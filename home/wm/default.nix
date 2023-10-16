{ config, pkgs, ... }:

{
    imports = [
        ./hyprland.nix
        ./vscode.nix
        ./browsers.nix
        ./waybar.nix
    ];

   	# Packages
	home.packages = with pkgs; [
		# Base
		alacritty
		pavucontrol
		pulseaudio
		flameshot
		networkmanagerapplet

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

    services.blueman-applet.enable = true;

	## Notification daemon
	services.mako = {
		enable = true;
		defaultTimeout = 7500;
		maxVisible = 3;
	};
}