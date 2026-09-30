{
  inputs,
  ...
}:
{
  # Secret handling
  flake-file.inputs.agenix = {
    url = "github:yaxitech/ragenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.secrets = {
    imports = [
      inputs.agenix.nixosModules.default
    ];
  };
}
