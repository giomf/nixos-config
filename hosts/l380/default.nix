{ pkgs, ... }:

{
  imports = [ ../common.nix ./greetd.nix ./hardware-configuration.nix ];

  system.stateVersion = "23.05";

  boot = {
    kernelParams = [ "quiet" ];
    initrd = {
      systemd.enable = true;
      availableKernelModules = [ "thinkpad_acpi" ];
    };
    plymouth.enable = true;
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 10;
      efi.canTouchEfiVariables = true;
    };
    initrd.luks.devices = {
      root = {
        device = "/dev/disk/by-uuid/c3363524-bc20-42b0-aadb-04b8f906a245";
        preLVM = true;
        allowDiscards = true;
      };
    };
    # Allow building img for pi
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  # Allow wayland support in all chrome and most electron apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [ ];
  environment.defaultPackages = with pkgs; [ ];

  xdg.portal = {
    config.common.default = "*";
    enable = true;
    wlr.enable = true;
  };

  programs = {
    # Needed for backlight controll as non root
    light.enable = true;
    virt-manager.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
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
    fwupd.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  # User
  users.users.guif = { extraGroups = [ "video" "audio" "networkmanager" "libvirtd" ]; };

  # Networking
  networking = {
    hostName = "glap";
    networkmanager.enable = true;
  };

  # Power management
  powerManagement.cpuFreqGovernor = "performance";

  # Hardware
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    graphics = {
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [ intel-compute-runtime intel-media-driver ];
    };
  };
}

