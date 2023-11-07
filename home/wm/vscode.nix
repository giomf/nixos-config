{ config, pkgs, ... }:

{

  # Packages
  home.packages = with pkgs; [
    # for nix IDE
    nixpkgs-fmt
    rnix-lsp
    # for bash IDE
    shellcheck
  ];

  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      rust-lang.rust-analyzer
      streetsidesoftware.code-spell-checker
      arrterian.nix-env-selector
      mads-hartmann.bash-ide-vscode
      foxundermoon.shell-format
      mhutchie.git-graph
      ms-vscode-remote.remote-ssh
      yzhang.markdown-all-in-one
	    eamodio.gitlens
      github.github-vscode-theme
    ];
    userSettings = {
      "workbench.colorTheme" = "GitHub Dark";
      "window.zoomLevel" = 2;
      "editor.tabSize" = 2;
      "editor.indentSize" = "tabSize";
      "editor.fontFamily" = "'FiraCode Nerd Font Mono', monospace";
      "editor.minimap.enabled" = false;
      "[nix]"."editor.tabSize" = 4;
      "nixEnvSelector.nixFile" = "\${workspaceRoot}/shell.nix";
      # Workaround for: https://github.com/NixOS/nixpkgs/issues/246509
      "window.titleBarStyle" = "custom";
    };
  };

}
