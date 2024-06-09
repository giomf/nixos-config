{ pkgs, ... }:

{
  imports = [
    ./kitty.nix
    ./browsers.nix
    ./hyprland.nix
#    ./keyring.nix
    # ./vscode.nix
    ./waybar.nix
  ];

  # Packages
  home.packages = with pkgs; [
    # Base
    networkmanagerapplet
    pavucontrol
    pulseaudio

    # Office
    gimp
    keepassxc
    libreoffice-qt
    thunderbird
    vlc
    xournal

    # 3D Printing
    cura
    freecad

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
