{ config, pkgs, ... }:

{
	home.packages = with pkgs; [
		google-chrome
	];

	programs.firefox = {
		enable = true;
		package = pkgs.firefox-wayland;
		profiles = {
			giom = {
				id = 0;
				name = "giom";
				extensions = with pkgs.nur.repos.rycee.firefox-addons; [
					ublock-origin
					darkreader
					keepassxc-browser
				];
			};
		};
	};
}