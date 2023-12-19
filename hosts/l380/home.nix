{ config, pkgs,  ... }:

{
  imports = [
    ../../home
    ../../home/wm
  ];

  # Packages
  home.packages = with pkgs; [
    usbutils
  ];
}
