{
  inputs,
  ...
}:
{
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [ inputs.home-manager.flakeModules.home-manager ];
  flake.modules.nixos.home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];
    home-manager = {
      verbose = true;
      useUserPackages = true;
      useGlobalPkgs = true;
    };
  };
}
