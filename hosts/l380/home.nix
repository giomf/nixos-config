{ config, pkgs, ... }:

{
  imports = [ ../../home ../../home/wm ];

  # Packages
  home.packages = with pkgs; [ usbutils ];

  # workaround for virt-manager
  # https://discourse.nixos.org/t/virt-manager-cannot-create-vm/38894/4
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
  };
}
