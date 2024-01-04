{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
    ./containers/pihole.nix
  ];

  system.stateVersion = "23.05";

  nix.settings.trusted-users = [ "@wheel" ];

  environment.systemPackages = with pkgs; [
    libraspberrypi
  ];
  environment.defaultPackages = with pkgs; [ ];

  # User
  users.users.guif = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPI4hVcnH2C5Rq0Pkgv+rw2h1dAm2QQdyboDfW7kUlw guif@glap"
    ];
  };

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
  };

  # Networking
  networking = {
    hostName = "pi";
    networkmanager.enable = true;
  };

  # Allow ssh in
  services.openssh.enable = true;

  sdImage.compressImage = false;
  # Workaround needed for: https://github.com/NixOS/nixpkgs/issues/154163
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];
}
