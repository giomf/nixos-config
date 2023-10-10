{ config, pkgs, ... }:

{
	programs.helix = {
		enable = true;
		defaultEditor = true;
#        settings = {
#            theme = "theme";
#        };
        themes = {
            theme = {
                ui = {
                    background = "black";
                };
            };
        };
	};
}