{ config, pkgs, ... }:

{
  imports = [
    ../../home
    ../../home/keyring.nix
  ];

  # # Needed packages for work
  # home.packages = with pkgs; [
  #   # for nix IDE
  #   nixpkgs-fmt
  #   # for bash IDE
  #   shellcheck
  #   # python
  #   python311Packages.python-lsp-server
  #   python310Packages.yapf
  #   # C++
  #   cmake
  #   clang-tools
  #   lldb

  #   sshfs
  # ];

  # xdg.configFile."zellij/layouts/musmol.kdl".source = ./musmol.kdl;
}
