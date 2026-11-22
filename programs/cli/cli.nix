{
  inputs,
  ...
}:
{
  flake-file.inputs.nix-index-database.url = "github:nix-community/nix-index-database";

  flake.modules.homeManager.cli =
    { pkgs, ... }:
    {

      imports = [
        inputs.nix-index-database.homeModules.default
      ];

      programs = {
        # Via programs.* so stylix can theme them on laptops
        bat.enable = true;
        btop.enable = true;
        zoxide.enable = true;
        # This will still use the nix-index-database
        nix-index.enable = true;
        nix-index-database = {
          comma.enable = true;
        };
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
      };

      home.packages = with pkgs; [
        # Base
        docker-compose
        doggo
        dua
        duf
        eza
        fd
        file
        hexyl
        kmon
        mcat
        mdcat
        nmap
        numbat
        openssl
        procs
        pwgen
        ripgrep
        sd
        tldr
        unzip
        wavemon
        wget

        # Coding
        gh
        git-crypt
        gnupg
        nixpkgs-review
      ];
    };
}
