{ config, pkgs, ... }:

{
    imports = [
    	../../home
    ];

    # Needed for vscode
    home.packages = with pkgs; [
    # for vscode
    nodejs
    # for nix IDE
		nixpkgs-fmt
		rnix-lsp
    # for bash IDE
    shellcheck ];

    xdg.configFile."zellij/layouts/musmol.kdl".source = ./musmol.kdl;
}