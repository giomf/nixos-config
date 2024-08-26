{ pkgs, ... }:

{
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = false;
  environment.cosmic.excludePackages = with pkgs; [
    cosmic-edit
    cosmic-files
    cosmic-term
    cosmic-store
  ];

}
