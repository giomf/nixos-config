{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
    ./greetd.nix
  ];

  system.stateVersion = "23.05";

  boot = {
    kernelParams = [ "quiet" ];
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 10;
      efi.canTouchEfiVariables = true;
    };
    # Allow building img for pi
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  environment.systemPackages = with pkgs; [ ];
  environment.defaultPackages = with pkgs; [
    usbutils
  ];

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  programs = {
    # Needed for backlight controll as non root
    light.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };

  # Security
  security = {
    pam.services.swaylock = { };
    # Enable sound
    rtkit.enable = true;
  };

  # Services
  services = {
    blueman.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  # User
  users.users.guif = {
    extraGroups = [
      "video"
      "audio"
      "networkmanager"
    ];
  };

  # Networking
  networking = {
    hostName = "glap";
    networkmanager.enable = true;
  };

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
}

