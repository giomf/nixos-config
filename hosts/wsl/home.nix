{ config, pkgs, ... }:

{
    imports = [
    	../../home
    ];

    xdg.configFile."zellij/layouts/musmol.kdl".source = ./musmol.kdl;
}