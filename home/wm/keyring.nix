{ pkgs, ... }:

{
  services.gnome-keyring.enable = true;
  home.packages = with pkgs; [ gnome.libgnome-keyring gnome.gnome-keyring gnome.seahorse ];
}
