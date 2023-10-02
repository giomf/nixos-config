{ config, pkgs, ... }:

{
    imports = [
        ./fish.nix
        ./wm
    ];

    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home = {
        username = "giom";
        homeDirectory = "/home/giom";

        # This value determines the Home Manager release that your
        # configuration is compatible with. This helps avoid breakage
        # when a new Home Manager release introduces backwards
        # incompatible changes.
        #
        # You can update Home Manager without changing this value. See
        # the Home Manager release notes for a list of state version
        # changes in each release.
        stateVersion = "23.05";
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;


	# Packages
	home.packages = with pkgs; [
		# Base
		ranger
		eza
		bat
		flameshot
		btop
		unzip

		# Coding
		git
		rustup
	];

	# Programs
    programs.zellij = {
        enable = true;
        enableFishIntegration = true;
    };

	programs.vim = {
		enable = true;
		defaultEditor = true;
	};

	# Services
	services.ssh-agent.enable = true;
}