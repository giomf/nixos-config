{ config, pkgs, ... }:

{
  imports = [
    ../../home
    ../../home/keyring.nix
  ];

  # Needed for vscode
  home.packages = with pkgs; [
    # for vscode
    nodejs
    # for nix IDE
    nixpkgs-fmt
    # for bash IDE
    shellcheck
    # python
    python311Packages.python-lsp-server
    python310Packages.yapf
    # C++
    cmake
    clang-tools
    lldb
  ];

  xdg.configFile."zellij/layouts/musmol.kdl".source = ./musmol.kdl;
}
