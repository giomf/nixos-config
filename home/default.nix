{ pkgs, ... }:

{
  imports = [
    ./fish.nix
    ./git.nix
    ./helix.nix
    ./starship.nix
    ./zellij.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = "guif";
    homeDirectory = "/home/guif";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "23.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;


  # Packages
  home.packages = with pkgs; [
    # Base
    bat
    btop
    direnv
    docker-compose
    dogdns
    du-dust
    duf
    eza
    fd
    file
    fzf
    hexyl
    kmon
    numbat
    procs
    ripgrep
    tldr
    unzip
    wget
    yazi

    # Coding
    gh
    git
    git-crypt
    gnupg
    nixpkgs-review
  ];

  # Services
  services.ssh-agent.enable = true;
  services.gpg-agent.enable = true;

}
