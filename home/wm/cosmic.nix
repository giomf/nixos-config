{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    cosmic-applets
    cosmic-comp
    cosmic-greeter
    cosmic-icons
    cosmic-launcher
    cosmic-osd
    cosmic-panel
    cosmic-settings
    cosmic-workspaces-epoch
  ];
}
