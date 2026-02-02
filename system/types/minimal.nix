{
  ...
}:
{
  flake.modules.nixos.system-minimal =
    { ... }:
    {
      nixpkgs.config.allowUnfree = true;
      nix = {
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          trusted-users = [ "@wheel" ];
        };
        registry = {
          nix-templates = {
            from = {
              id = "nix-templates";
              type = "indirect";
            };
            to = {
              type = "github";
              owner = "giomf";
              repo = "nix-templates";
            };
          };
        };
      };
    };

  flake.modules.homeManager.system-minimal =
    { config, ... }:
    {
      home.stateVersion = "23.05";
      home.homeDirectory = "/home/${config.home.username}";
      programs = {
        home-manager.enable = true;
      };
    };
}
