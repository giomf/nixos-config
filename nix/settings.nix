{
  ...
}:
{
  flake.modules.nixos.nix-settings =
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
      };
    };

}
