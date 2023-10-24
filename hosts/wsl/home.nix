{ config, pkgs, ... }:

{
    imports = [
    	../../home
    ];

    # Needed for vscode
    home.packages = with pkgs; [ nodejs ];

    xdg.configFile."zellij/layouts/musmol.kdl".source = ./musmol.kdl;
}