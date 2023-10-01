{ config, pkgs, ... }:

{
	imports = [ # Include the results of the hardware scan.
		./hardware-configuration.nix
		./greetd.nix
		<home-manager/nixos>
	];

	system.stateVersion = "23.05";
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	# Bootloader
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	time.timeZone = "Europe/Berlin";
	console = {
		keyMap = "de";
		packages = with pkgs; [ terminus_font ];
		font = "ter-u28n";
	};

	# Packages
	nixpkgs.config.packageOverrides = pkgs: {
		nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
			inherit pkgs;
		};
  	};
	
	nixpkgs.config.allowUnfree = true;
	environment.defaultPackages = with pkgs; [];
	environment.systemPackages = with pkgs; [];

	# Needed for backlight controll as non root
	programs.light.enable = true;
	programs.fish.enable = true;

	# Security
	security.polkit.enable = true;
	security.sudo.wheelNeedsPassword = false;
	security.pam.services.swaylock = {};

	# Services
	services.openssh.enable = true;
	services.openssh.settings.PermitRootLogin = "yes";
	services.blueman.enable = true;
	
	fonts = {
		packages = with pkgs; [
			font-awesome
			dejavu_fonts
			source-code-pro
			source-sans-pro
			source-serif-pro
			(nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
		];
		fontconfig = {
			defaultFonts = {
				monospace = [ "Source Code Pro" ];
				sansSerif = [ "Source Sans Pro" ];
				serif     = [ "Source Serif Pro" ];
			};
		};
	};

	# User
	users.users.giom = {
		isNormalUser = true;
		shell = pkgs.fish;
		extraGroups = [
			"wheel"
			"video"
			"audio"
			"networkmanager"
		];
		openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPI4hVcnH2C5Rq0Pkgv+rw2h1dAm2QQdyboDfW7kUlw giom" ];
	};

	# Networking
	networking.networkmanager.enable = true;

	# Power management
  	powerManagement.cpuFreqGovernor = "performance";

	# Hardware
	hardware = {
		bluetooth.enable = true;
		opengl = {
			enable = true;
			driSupport = true;
			extraPackages = with pkgs; [
				intel-compute-runtime
				intel-media-driver
			];
		};
	};

  # Enable sound.
  	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		# If you want to use JACK applications, uncomment this
		#jack.enable = true;
	};

	# Home-manager
	home-manager.useGlobalPkgs = true;
	home-manager.users.giom = import ./home.nix;
}

