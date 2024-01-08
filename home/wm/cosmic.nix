{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    cosmic-comp
    cosmic-osd
    cosmic-panel
    cosmic-icons
    cosmic-greeter
    cosmic-settings
    cosmic-launcher
    cosmic-applets
    cosmic-workspaces-epoch
  ];
}
