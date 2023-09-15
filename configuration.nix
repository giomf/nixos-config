{ config, pkgs, ... }:

{
	imports =
		[ # Include the results of the hardware scan.
		./hardware-configuration.nix
		./greetd.nix
		<home-manager/nixos>
		];

	system.stateVersion = "23.05";
	nix.settings.experimental-features = [ "nix-command" "flakes" ];
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	time.timeZone = "Europe/Berlin";

	console = {
		keyMap = "de";
		packages = with pkgs; [ terminus_font ];
		font = "ter-u28n";
	};

	# Packages
	nixpkgs.config.allowUnfree = true;
	environment.systemPackages = with pkgs; [
	];


	# Needed for backlight controll as non root
	programs.light.enable = true;

	# Security
	security.polkit.enable = true;
	security.sudo.wheelNeedsPassword = false;
	security.pam.services.swaylock = {};

	# Services
	services.openssh.enable = true;
	services.openssh.settings.PermitRootLogin = "yes";
	
	fonts = {
		packages = with pkgs; [
		dejavu_fonts
		source-code-pro
		source-sans-pro
		source-serif-pro
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
		extraGroups = [
			"wheel"
			"video"
			"audio"
			"networkmanager"
		];
		openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPI4hVcnH2C5Rq0Pkgv+rw2h1dAm2QQdyboDfW7kUlw giom@glap" ];
	};

	## Enable the X11 windowing system.
	#services.xserver = {
	#	enable = true;
	#	layout = "de";
	#	videoDrivers = [ "x86video" ];
	#	displayManager.lightdm.enable = true;
	#	windowManager.i3.enable = true;
	#};

	# Networking
	networking.networkmanager.enable = true;
	
  	powerManagement.cpuFreqGovernor = "performance";
	# GPU
	hardware.opengl = {
		enable = true;
		driSupport = true;
		extraPackages = with pkgs; [
			intel-compute-runtime
			intel-media-driver
		];
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

