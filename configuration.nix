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
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  # Packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = [
  ];

  # Security
  security.polkit.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Services
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  # User
  users.users.giom = {
    initialPassword = "afsd";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPI4hVcnH2C5Rq0Pkgv+rw2h1dAm2QQdyboDfW7kUlw giom@glap" ];
  };

  # Home-manager
  home-manager.useGlobalPkgs = true;
  home-manager.users.giom = import ./home.nix;

}

