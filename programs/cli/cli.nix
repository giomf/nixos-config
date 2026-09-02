{
  inputs,
  ...
}:
{

  flake.modules.homeManager.cli =
    { pkgs, ... }:
    {

      imports = [
        inputs.nix-index-database.homeModules.default
      ];

      programs = {
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
        bat
        btop
        docker-compose
        doggo
        dua
        duf
        eza
        fd
        file
        hexyl
        kmon
        nmap
        numbat
        openssl
        procs
        pwgen
        ripgrep
        sd
        tldr
        unzip
        wget
        yazi

        # Coding
        claude-code
        github-copilot-cli
        gh
        git-crypt
        gnupg
        nixpkgs-review
      ];
    };
}
