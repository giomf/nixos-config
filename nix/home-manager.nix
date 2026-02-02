{
  inputs,
  ...
}:
{
  imports = [ inputs.home-manager.flakeModules.home-manager ];
  flake.modules.nixos.home-manager = {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          extraSpecialArgs = {
            cosmic-manager = inputs.cosmic-manager;
          };
        };
      }
    ];
    home-manager = {
      verbose = true;
      useUserPackages = true;
      useGlobalPkgs = true;
    };
  };
}
