{ config, pkgs, ... }:

{
  home.stateVersion = "23.05";
  home.username = "giom";
  home.homeDirectory = "/home/giom";

  home.packages = with pkgs; [
    # Base
    vim
    alacritty
    dmenu
    ranger

    # Coding
    git
    vscode
    rustup

    # Office
    firefox-wayland
    google-chrome
    thunderbird
    libreoffice-qt
    keepassxc
    
    # Social
    telegram-desktop
    element-desktop
    spotify
    nextcloud-client                       
  ];

  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "alacritty";
      menu = "dmenu_run";
      defaultWorkspace = "workspace number 1";
      gaps = {
        smartBorders = "on";
      };
      keybindings = {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+Space" = "exec ${menu}";
        "${modifier}+Shift+Return" = "exec firefox";
        
        "${modifier}+Up" = "focus up";
        "${modifier}+w" = "focus up";
        "${modifier}+Down" = "focus down";
        "${modifier}+s" = "focus down";
        "${modifier}+Left" = "focus left";
        "${modifier}+a" = "focus left";
        "${modifier}+Right" = "focus right";
        "${modifier}+d" = "focus right";

        "${modifier}+q" = "kill";

        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        "${modifier}+0" = "workspace number 10";

        "${modifier}+Shift+r" = "reload";
        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
