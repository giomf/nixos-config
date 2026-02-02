{
  flake.modules.homeManager.cli =
    { pkgs, ... }:
    {

      programs = {
        zoxide.enable = true;
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
        termscp
        tldr
        unzip
        wget
        yazi

        # Coding
        aider-chat
        gh
        git-crypt
        gnupg
        nixpkgs-review
      ];
    };
}
