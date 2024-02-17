{ pkgs, ... }:

{
  imports = [
    ./alacritty.nix
    ./browsers.nix
    ./hyprland.nix
#    ./keyring.nix
    ./vscode.nix
    ./waybar.nix
  ];

  # Packages
  home.packages = with pkgs; [
    # Base
    networkmanagerapplet
    pavucontrol
    pulseaudio

    # Office
    keepassxc
    libreoffice-qt
    thunderbird
    xournal
    vlc

    # Social
    discord
    element-desktop
    nextcloud-client
    spotify
    telegram-desktop
  ];

  services.blueman-applet.enable = true;

  ## Notification daemon
  services.mako = {
    enable = true;
    defaultTimeout = 7500;
    maxVisible = 3;
  };
}
