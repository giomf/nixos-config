{
  inputs,
  ...
}:
{
  # The home-manager inputs and nixosModules are chosen per host, to match its nixpkgs channel
  imports = [ inputs.home-manager.flakeModules.home-manager ];
  flake.modules.nixos.home-manager = {
    home-manager = {
      verbose = true;
      useUserPackages = true;
      useGlobalPkgs = true;
    };
  };
}
